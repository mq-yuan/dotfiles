#!/usr/bin/env python3
"""
Camera Path Generator

A standalone tool for generating camera paths for 3D scenes. 
It supports two modes of camera path generation:
1. Full 360° orbit around a scene
2. Constrained path that follows the angular coverage of input cameras

This tool can be used to create camera trajectories for rendering videos of 3D scenes.

Example usage:
    # Generate a full orbit path
    python camera_path_generator.py --input cameras.json --output orbit_path.json --orbit --frames 120
    
    # Generate a constrained path
    python camera_path_generator.py --input cameras.json --output constrained_path.json --constrained --frames 180 --z-variation 0.5
    
    # Use a camera selection file
    python camera_path_generator.py --input cameras.json --output path.json --orbit --selection camera_selection.json
    
    # Adjust output resolution
    python camera_path_generator.py --input cameras.json --output path.json --orbit --resolution-scale 0.5
"""

import argparse
import copy
import json
import numpy as np
import os
import torch
from typing import List, Tuple, Dict, Any, Optional

class Camera:
    """
    Camera class that stores essential camera parameters.
    Simplified from the original Camera class for path generation.
    """
    def __init__(
        self,
        R=None,
        T=None,
        FoVx=None,
        FoVy=None,
        world_view_transform=None,
        projection_matrix=None,
        image_height=1080,
        image_width=1920,
        uid=0,
        colmap_id=0,
        image_name="",
        znear=0.01,
        zfar=100.0,
        device="cuda"
    ):
        self.uid = uid
        self.colmap_id = colmap_id
        self.R = R
        self.T = T
        self.FoVx = FoVx
        self.FoVy = FoVy
        self.image_name = image_name
        self.image_height = image_height
        self.image_width = image_width
        self.znear = znear
        self.zfar = zfar
        
        # Set device
        try:
            self.device = torch.device(device)
        except Exception as e:
            print(f"[Warning] Custom device {device} failed, fallback to default cuda device")
            self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        # Set up camera transforms
        if world_view_transform is not None:
            self.world_view_transform = world_view_transform
        elif R is not None and T is not None:
            from utils.graphics_utils import getWorld2View2
            self.world_view_transform = torch.tensor(
                getWorld2View2(R, T, np.array([0.0, 0.0, 0.0]), 1.0)
            ).transpose(0, 1).to(self.device)

        if projection_matrix is not None:
            self.projection_matrix = projection_matrix
        elif FoVx is not None and FoVy is not None:
            from utils.graphics_utils import getProjectionMatrix
            self.projection_matrix = getProjectionMatrix(
                znear=self.znear, zfar=self.zfar, 
                fovX=self.FoVx, fovY=self.FoVy
            ).transpose(0, 1).to(self.device)
        
        # Calculate full projection transform and camera center
        if hasattr(self, 'world_view_transform') and hasattr(self, 'projection_matrix'):
            self.full_proj_transform = (
                self.world_view_transform.unsqueeze(0).bmm(
                    self.projection_matrix.unsqueeze(0)
                )
            ).squeeze(0)
            self.camera_center = self.world_view_transform.inverse()[3, :3]
    
    @property
    def c2w(self):
        """Get camera-to-world transformation matrix"""
        return self.world_view_transform.transpose(0, 1).inverse()
    
    @property
    def w2c(self):
        """Get world-to-camera transformation matrix"""
        return self.world_view_transform.transpose(0, 1)

    @classmethod
    def from_dict(cls, data: Dict[str, Any], device: str = "cuda") -> "Camera":
        """Create a camera from a dictionary (loaded from JSON)"""
        # Required parameters
        kwargs = {
            "device": device,
            "image_height": data.get("image_height", 1080),
            "image_width": data.get("image_width", 1920),
            "uid": data.get("uid", 0),
            "colmap_id": data.get("colmap_id", 0),
            "image_name": data.get("image_name", ""),
            "znear": data.get("znear", 0.01),
            "zfar": data.get("zfar", 100.0)
        }
        
        # Handle transforms
        if "world_view_transform" in data:
            kwargs["world_view_transform"] = torch.tensor(
                data["world_view_transform"], dtype=torch.float32, device=device
            )
        
        if "projection_matrix" in data:
            kwargs["projection_matrix"] = torch.tensor(
                data["projection_matrix"], dtype=torch.float32, device=device
            )
            
        if "R" in data:
            kwargs["R"] = np.array(data["R"])
            
        if "T" in data:
            kwargs["T"] = np.array(data["T"])
            
        if "FoVx" in data:
            kwargs["FoVx"] = data["FoVx"]
            
        if "FoVy" in data:
            kwargs["FoVy"] = data["FoVy"]
            
        return cls(**kwargs)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert camera to dictionary for JSON serialization"""
        data = {
            "image_height": self.image_height,
            "image_width": self.image_width,
            "uid": self.uid,
            "colmap_id": self.colmap_id,
            "image_name": self.image_name,
            "znear": self.znear,
            "zfar": self.zfar
        }
        
        # Include transforms
        if hasattr(self, 'world_view_transform'):
            data["world_view_transform"] = self.world_view_transform.cpu().numpy().tolist()
        
        if hasattr(self, 'projection_matrix'):
            data["projection_matrix"] = self.projection_matrix.cpu().numpy().tolist()
            
        if hasattr(self, 'R') and self.R is not None:
            data["R"] = self.R.tolist() if isinstance(self.R, np.ndarray) else self.R
            
        if hasattr(self, 'T') and self.T is not None:
            data["T"] = self.T.tolist() if isinstance(self.T, np.ndarray) else self.T
            
        if hasattr(self, 'FoVx'):
            data["FoVx"] = self.FoVx
            
        if hasattr(self, 'FoVy'):
            data["FoVy"] = self.FoVy
            
        return data

# ---- Utility functions for camera path generation ----

def normalize(x: np.ndarray) -> np.ndarray:
    """Normalize a vector to unit length."""
    return x / np.linalg.norm(x)

def pad_poses(p: np.ndarray) -> np.ndarray:
    """Pad [..., 3, 4] pose matrices with a homogeneous bottom row [0,0,0,1]."""
    bottom = np.broadcast_to([0, 0, 0, 1.], p[..., :1, :4].shape)
    return np.concatenate([p[..., :3, :4], bottom], axis=-2)

def unpad_poses(p: np.ndarray) -> np.ndarray:
    """Remove the homogeneous bottom row from [..., 4, 4] pose matrices."""
    return p[..., :3, :4]

def viewmatrix(lookdir: np.ndarray, up: np.ndarray, position: np.ndarray) -> np.ndarray:
    """Construct lookat view matrix."""
    vec2 = normalize(lookdir)
    vec0 = normalize(np.cross(up, vec2))
    vec1 = normalize(np.cross(vec2, vec0))
    m = np.stack([vec0, vec1, vec2, position], axis=1)
    return m

def focus_point_fn(poses: np.ndarray) -> np.ndarray:
    """Calculate nearest point to all focal axes in poses."""
    directions, origins = poses[:, :3, 2:3], poses[:, :3, 3:4]
    m = np.eye(3) - directions * np.transpose(directions, [0, 2, 1])
    mt_m = np.transpose(m, [0, 2, 1]) @ m
    focus_pt = np.linalg.inv(mt_m.mean(0)) @ (mt_m @ origins).mean(0)[:, 0]
    return focus_pt

def transform_poses_pca(poses: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Transform poses so principal components lie on XYZ axes.
    
    Args:
        poses: a (N, 3, 4) array containing the cameras' camera to world transforms.
    
    Returns:
        A tuple (poses, transform), with the transformed poses and the applied
        camera_to_world transforms.
    """
    t = poses[:, :3, 3]
    t_mean = t.mean(axis=0)
    t = t - t_mean
    
    eigval, eigvec = np.linalg.eig(t.T @ t)
    # Sort eigenvectors in order of largest to smallest eigenvalue.
    inds = np.argsort(eigval)[::-1]
    eigvec = eigvec[:, inds]
    rot = eigvec.T
    if np.linalg.det(rot) < 0:
        rot = np.diag(np.array([1, 1, -1])) @ rot
    
    transform = np.concatenate([rot, rot @ -t_mean[:, None]], -1)
    poses_recentered = unpad_poses(transform @ pad_poses(poses))
    transform = np.concatenate([transform, np.eye(4)[3:]], axis=0)
    
    # Flip coordinate system if z component of y-axis is negative
    if poses_recentered.mean(axis=0)[2, 1] < 0:
        poses_recentered = np.diag(np.array([1, -1, -1])) @ poses_recentered
        transform = np.diag(np.array([1, -1, -1, 1])) @ transform
    
    return poses_recentered, transform

def generate_ellipse_path(
    poses: np.ndarray,
    n_frames: int = 120,
    z_variation: float = 0.0,
    z_phase: float = 0.0
) -> np.ndarray:
    """
    Generate an elliptical render path based on the given poses.
    
    Args:
        poses: Input camera poses in format (N, 3, 4)
        n_frames: Number of frames for the output trajectory
        z_variation: Amount of vertical variation (0=flat path, 1=full height range)
        z_phase: Phase offset for z oscillation (0-1)
        
    Returns:
        Array of camera poses for the path
    """
    # Calculate the focal point for the path (cameras point toward this).
    center = focus_point_fn(poses)
    # Path height sits at z=0 (in middle of zero-mean capture pattern).
    offset = np.array([center[0], center[1], 0])
    
    # Calculate scaling for ellipse axes based on input camera positions.
    sc = np.percentile(np.abs(poses[:, :3, 3] - offset), 90, axis=0)
    # Use ellipse that is symmetric about the focal point in xy.
    low = -sc + offset
    high = sc + offset
    # Optional height variation need not be symmetric
    z_low = np.percentile((poses[:, :3, 3]), 10, axis=0)
    z_high = np.percentile((poses[:, :3, 3]), 90, axis=0)
    
    def get_positions(theta):
        # Interpolate between bounds with trig functions to get ellipse in x-y.
        # Optionally also interpolate in z to change camera height along path.
        return np.stack([
            low[0] + (high - low)[0] * (np.cos(theta) * .5 + .5),
            low[1] + (high - low)[1] * (np.sin(theta) * .5 + .5),
            z_variation * (z_low[2] + (z_high - z_low)[2] *
                         (np.cos(theta + 2 * np.pi * z_phase) * .5 + .5)),
        ], -1)
    
    theta = np.linspace(0, 2. * np.pi, n_frames + 1, endpoint=True)
    positions = get_positions(theta)
    
    # Throw away duplicated last position.
    positions = positions[:-1]
    
    # Set path's up vector to axis closest to average of input pose up vectors.
    avg_up = poses[:, :3, 1].mean(0)
    avg_up = avg_up / np.linalg.norm(avg_up)
    ind_up = np.argmax(np.abs(avg_up))
    up = np.eye(3)[ind_up] * np.sign(avg_up[ind_up])
    
    return np.stack([viewmatrix(p - center, up, p) for p in positions])

def generate_constrained_path(
    poses: np.ndarray,
    n_frames: int = 120,
    z_variation_scale: float = 0.4,
    radius_variation_scale: float = 0.15
) -> np.ndarray:
    """
    Generate a camera path constrained to the angular coverage of input cameras.
    Creates a loop with distinct outbound and return paths.
    
    Args:
        poses: Input camera poses in format (N, 3, 4)
        n_frames: Number of frames for the output trajectory
        z_variation_scale: Scale factor for vertical variation between paths
        radius_variation_scale: Scale factor for radius variation
        
    Returns:
        Array of camera poses for the constrained path
    """
    # Calculate the focal point for the path
    center = focus_point_fn(poses)
    
    # Analyze the angular coverage of original cameras
    cam_positions = poses[:, :3, 3]  # Camera positions
    cam_directions = np.array([p - center for p in cam_positions])
    
    # Calculate angles in the horizontal plane (xy-plane)
    angles = np.arctan2(cam_directions[:, 1], cam_directions[:, 0])
    
    # Find the min/max angles, handling the wrap-around at ±π
    angle_range = np.ptp(angles)
    if angle_range > np.pi:
        # If cameras cover more than 180 degrees, we need to handle the discontinuity
        # Convert angles to ensure they're continuous
        min_angle = np.min(angles)
        angles_shifted = np.where(angles < min_angle + np.pi, angles, angles - 2*np.pi)
        min_angle = np.min(angles_shifted)
        max_angle = np.max(angles_shifted)
    else:
        min_angle = np.min(angles)
        max_angle = np.max(angles)
    
    # Add a small buffer to ensure we stay within observed regions
    buffer = 0.05 * (max_angle - min_angle)  # Small buffer for better coverage
    min_angle += buffer
    max_angle -= buffer
    
    # Find vertical (z) range of cameras
    z_min = np.min(cam_positions[:, 2])
    z_max = np.max(cam_positions[:, 2])
    z_mid = np.mean(cam_positions[:, 2])
    z_range = max(z_max - z_min, 0.1)  # Ensure some minimum range
    
    # Calculate camera distances from center (for varying radius)
    distances = np.linalg.norm(cam_positions[:, :2] - center[:2], axis=1)
    avg_radius = np.mean(distances)
    
    # Generate positions along an arc and back with both vertical and radius variation
    def get_positions(t):
        # Use smooth easing function for transitions (cubic ease-in-out)
        def ease_cubic(x):
            return 3 * x**2 - 2 * x**3
            
        # First half: Go from min_angle to max_angle with lower path
        # Second half: Return from max_angle to min_angle with higher path
        if t < 0.5:
            # Outbound journey (0 -> 0.5 maps to 0 -> 1)
            normalized_t = t * 2
            # Apply easing for smoother motion around transition points
            eased_t = ease_cubic(normalized_t)
            theta = min_angle + eased_t * (max_angle - min_angle)
            
            # Lower path - dip down slightly
            z_offset = -z_variation_scale * z_range * np.sin(np.pi * normalized_t)
            
            # Slight inward radius for lower path
            radius_factor = 1.0 - radius_variation_scale * np.sin(np.pi * normalized_t)
        else:
            # Return journey (0.5 -> 1.0 maps to 1 -> 0)
            normalized_t = 2 - t * 2
            # Apply easing for smoother motion
            eased_t = ease_cubic(normalized_t)
            theta = min_angle + eased_t * (max_angle - min_angle)
            
            # Higher path - rise up slightly
            z_offset = z_variation_scale * z_range * np.sin(np.pi * normalized_t)
            
            # Slight outward radius for higher path
            radius_factor = 1.0 + radius_variation_scale * np.sin(np.pi * normalized_t)
        
        # Calculate base radius and apply variation
        xy_radius = avg_radius * radius_factor
        
        # Calculate positions in the xy-plane
        x = center[0] + xy_radius * np.cos(theta)
        y = center[1] + xy_radius * np.sin(theta)
        
        # Add vertical variation between outbound and return paths
        z = z_mid + z_offset
        
        return np.array([x, y, z])
    
    # Generate evenly spaced positions
    t_vals = np.linspace(0, 1, n_frames)
    positions = np.array([get_positions(t) for t in t_vals])
    
    # Set path's up vector to axis closest to average of input pose up vectors
    avg_up = poses[:, :3, 1].mean(0)
    avg_up = avg_up / np.linalg.norm(avg_up)
    ind_up = np.argmax(np.abs(avg_up))
    up = np.eye(3)[ind_up] * np.sign(avg_up[ind_up])
    
    # Create viewmatrices for each position
    return np.stack([viewmatrix(p - center, up, p) for p in positions])

# ---- Main camera path generation functions ----

def generate_orbit_path(cameras: List[Camera], n_frames: int = 120) -> List[Camera]:
    """
    Generate a full 360° orbit camera path.
    
    Args:
        cameras: List of input cameras
        n_frames: Number of frames for the output path
        
    Returns:
        List of cameras representing the orbit path
    """
    # Extract camera poses
    c2ws = np.array([
        np.linalg.inv(np.asarray((cam.world_view_transform.T).cpu().numpy())) 
        for cam in cameras
    ])
    
    # Apply coordinate transform for standard representation
    pose = c2ws[:,:3,:] @ np.diag([1, -1, -1, 1])
    pose_recenter, colmap_to_world_transform = transform_poses_pca(pose)
    
    # Generate new poses in a 360° elliptical path
    new_poses = generate_ellipse_path(poses=pose_recenter, n_frames=n_frames)
    
    # Transform back to original coordinate system
    new_poses = np.linalg.inv(colmap_to_world_transform) @ pad_poses(new_poses)
    
    # Create camera objects for each pose
    traj = []
    for c2w in new_poses:
        c2w = c2w @ np.diag([1, -1, -1, 1])
        cam = copy.deepcopy(cameras[0])
        cam.image_height = int(cam.image_height / 2) * 2  # Ensure even dimensions
        cam.image_width = int(cam.image_width / 2) * 2
        cam.world_view_transform = torch.from_numpy(
            np.linalg.inv(c2w).T
        ).float().to(cam.device)
        cam.full_proj_transform = (
            cam.world_view_transform.unsqueeze(0).bmm(
                cam.projection_matrix.unsqueeze(0)
            )
        ).squeeze(0)
        cam.camera_center = cam.world_view_transform.inverse()[3, :3]
        traj.append(cam)
    
    return traj

def generate_constrained_camera_path(
    cameras: List[Camera], 
    n_frames: int = 120,
    z_variation: float = 0.4,
    radius_variation: float = 0.15
) -> List[Camera]:
    """
    Generate a camera path constrained to the angular range of input cameras.
    
    Args:
        cameras: List of input cameras
        n_frames: Number of frames for the output path
        z_variation: Amount of vertical variation between outbound and return paths (0-1)
        radius_variation: Amount of radius variation (0-1)
        
    Returns:
        List of cameras representing the constrained path
    """
    # Extract camera poses
    c2ws = np.array([
        np.linalg.inv(np.asarray((cam.world_view_transform.T).cpu().numpy())) 
        for cam in cameras
    ])
    
    # Apply coordinate transform for standard representation
    pose = c2ws[:,:3,:] @ np.diag([1, -1, -1, 1])
    pose_recenter, colmap_to_world_transform = transform_poses_pca(pose)
    
    # Generate new poses along a constrained path
    new_poses = generate_constrained_path(
        poses=pose_recenter, 
        n_frames=n_frames,
        z_variation_scale=z_variation,
        radius_variation_scale=radius_variation
    )
    
    # Transform back to original coordinate system
    new_poses = np.linalg.inv(colmap_to_world_transform) @ pad_poses(new_poses)
    
    # Create camera objects for each pose
    traj = []
    for c2w in new_poses:
        c2w = c2w @ np.diag([1, -1, -1, 1])
        cam = copy.deepcopy(cameras[0])
        cam.image_height = int(cam.image_height / 2) * 2  # Ensure even dimensions
        cam.image_width = int(cam.image_width / 2) * 2
        cam.world_view_transform = torch.from_numpy(
            np.linalg.inv(c2w).T
        ).float().to(cam.device)
        cam.full_proj_transform = (
            cam.world_view_transform.unsqueeze(0).bmm(
                cam.projection_matrix.unsqueeze(0)
            )
        ).squeeze(0)
        cam.camera_center = cam.world_view_transform.inverse()[3, :3]
        traj.append(cam)
    
    return traj

# ---- File handling functions ----

def load_cameras_from_file(filepath: str, device: str = "cuda" if torch.cuda.is_available() else "cpu") -> List[Camera]:
    """
    Load camera data from a JSON file.
    
    Args:
        filepath: Path to the JSON file
        device: Device to load tensors to ("cuda" or "cpu")
        
    Returns:
        List of Camera objects
    """
    with open(filepath, 'r') as f:
        data = json.load(f)
    
    cameras = []
    if "cameras" in data:
        for cam_data in data["cameras"]:
            cameras.append(Camera.from_dict(cam_data, device=device))
    else:
        # Handle legacy format or single camera object
        cameras.append(Camera.from_dict(data, device=device))
    
    print(f"Loaded {len(cameras)} cameras from {filepath}")
    return cameras

def save_cameras_to_file(cameras: List[Camera], filepath: str) -> None:
    """
    Save camera data to a JSON file.
    
    Args:
        cameras: List of Camera objects
        filepath: Output JSON file path
    """
    data = {
        "cameras": [cam.to_dict() for cam in cameras],
        "num_cameras": len(cameras)
    }
    
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"Saved {len(cameras)} cameras to {filepath}")

def process_camera_selection(cameras: List[Camera], selection_path: Optional[str] = None) -> List[Camera]:
    """
    Process camera selection from a JSON file or return all cameras.
    
    Args:
        cameras: List of all available cameras
        selection_path: Path to a JSON file with camera selection data
        
    Returns:
        List of selected Camera objects
    """
    if selection_path and os.path.exists(selection_path):
        print(f"Found camera selection file: {selection_path}")
        with open(selection_path, 'r') as f:
            selection_data = json.load(f)
            indices = selection_data.get('selected_camera_indices', [])
            
            if indices:
                print(f"Using {len(indices)} selected cameras from indices: {indices}")
                return [cameras[i] for i in indices if i < len(cameras)]
    
    print("Using all available cameras")
    return cameras

# ---- Main script functionality ----

def main():
    parser = argparse.ArgumentParser(description="Generate camera paths for 3D scene rendering")
    
    # Input/Output options
    parser.add_argument("--input", type=str, required=True, 
                        help="Input JSON file with camera parameters")
    parser.add_argument("--output", type=str, required=True,
                        help="Output JSON file to save generated camera path")
    parser.add_argument("--selection", type=str, default=None,
                        help="Optional JSON file with selected camera indices")
    
    # Path generation options
    path_group = parser.add_mutually_exclusive_group(required=True)
    path_group.add_argument("--orbit", action="store_true",
                          help="Generate a full 360° orbit camera path")
    path_group.add_argument("--constrained", action="store_true",
                          help="Generate a camera path constrained to input camera coverage")
    
    # Additional parameters
    parser.add_argument("--frames", type=int, default=120,
                        help="Number of frames in the output path (default: 120)")
    parser.add_argument("--z-variation", type=float, default=0.4,
                        help="Amount of vertical variation in the path (0-1, default: 0.4)")
    parser.add_argument("--radius-variation", type=float, default=0.15,
                        help="Amount of radius variation in the path (0-1, default: 0.15)")
    parser.add_argument("--device", type=str, default="cuda" if torch.cuda.is_available() else "cpu",
                        choices=["cuda", "cpu"], 
                        help="Device to use for tensor operations (default: cuda if available)")
    parser.add_argument("--resolution-scale", type=float, default=1.0,
                        help="Scale factor for camera resolution (default: 1.0)")
    
    args = parser.parse_args()
    
    print(f"Loading cameras from: {args.input}")
    cameras = load_cameras_from_file(args.input, device=args.device)
    
    # Process camera selection if provided
    if args.selection:
        cameras = process_camera_selection(cameras, args.selection)
    
    # Generate camera path based on selected method
    if args.orbit:
        print(f"Generating {args.frames} cameras for full 360° orbit path")
        output_cameras = generate_orbit_path(cameras, n_frames=args.frames)
    else:  # constrained
        print(f"Generating {args.frames} cameras for constrained path")
        output_cameras = generate_constrained_camera_path(
            cameras, 
            n_frames=args.frames,
            z_variation=args.z_variation,
            radius_variation=args.radius_variation
        )
    
    # Apply resolution scaling if needed
    if args.resolution_scale != 1.0:
        for cam in output_cameras:
            cam.image_height = int(cam.image_height * args.resolution_scale)
            cam.image_width = int(cam.image_width * args.resolution_scale)
            # Ensure dimensions are even
            cam.image_height = int(cam.image_height / 2) * 2
            cam.image_width = int(cam.image_width / 2) * 2
    
    # Save result
    save_cameras_to_file(output_cameras, args.output)
    print(f"Camera path generation complete. Output saved to: {args.output}")
    print(f"Generated {len(output_cameras)} camera frames")
    print(f"Resolution: {output_cameras[0].image_width}x{output_cameras[0].image_height}")

# Helper functions for integration with other projects
def create_from_colmap_cameras(colmap_cameras, n_frames=120, mode="orbit", z_variation=0.4, radius_variation=0.15):
    """
    Create a camera path from COLMAP camera objects.
    
    Args:
        colmap_cameras: List of camera objects from COLMAP
        n_frames: Number of frames for the output path
        mode: Path generation mode ("orbit" or "constrained")
        z_variation: Amount of vertical variation in constrained path
        radius_variation: Amount of radius variation in constrained path
        
    Returns:
        List of Camera objects representing the generated path
    """
    if mode == "orbit":
        return generate_orbit_path(colmap_cameras, n_frames=n_frames)
    else:  # constrained
        return generate_constrained_camera_path(
            colmap_cameras, 
            n_frames=n_frames,
            z_variation=z_variation,
            radius_variation=radius_variation
        )

def save_camera_selection(camera_indices, filepath):
    """
    Save a camera selection to a JSON file.
    
    Args:
        camera_indices: List of camera indices to select
        filepath: Output JSON file path
    """
    data = {
        "selected_camera_indices": camera_indices
    }
    
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"Saved camera selection with {len(camera_indices)} indices to {filepath}")

if __name__ == "__main__":
    main()

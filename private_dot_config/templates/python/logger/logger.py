from __future__ import annotations

import datetime
import logging
import sys
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class LoggerCfg:
    """Configuration for the logging system.

    Attributes:
        dir: The directory where log files will be saved.
        filename: The prefix of the log filename.
        filemode: The file opening mode (e.g., 'a' for append, 'w' for write).
        level: The logging level (e.g., 'INFO', 'DEBUG').
        project_prefixes: A list of package prefixes. Loggers matching these
            prefixes will be forced to propagate logs to the root logger.
    """

    # logger file config
    dir: str = "debug"
    filename: str = "log"
    filemode: str = "a"

    # logger level
    # Note: Modern OmegaConf supports Literal, but using str is safer for
    # compatibility with older Hydra versions.
    level: str = "INFO"

    # Use native list syntax
    project_prefixes: list[str] = field(default_factory=list)


def setup_logging_from_cfg(log_cfg: LoggerCfg) -> logging.Logger:
    """Configures the root logger based on the provided Hydra configuration.

    This function sets up file and stream handlers. It also enforces a unified
    logging policy for specific project modules defined in `project_prefixes`.

    Args:
        log_cfg: The configuration object containing logging settings.

    Returns:
        The fully configured root logger instance.
    """
    log_dir = Path(log_cfg.dir)
    log_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"{log_cfg.filename}_{timestamp}.log"
    log_path = log_dir / filename

    level_name = log_cfg.level.upper()
    level = getattr(logging, level_name, logging.INFO)

    # Configure Root Logger
    root_logger = logging.getLogger()
    root_logger.setLevel(level)
    root_logger.handlers.clear()

    log_format = (
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)"
    )
    formatter = logging.Formatter(log_format)

    file_handler = logging.FileHandler(
        log_path, mode=log_cfg.filemode, encoding="utf-8"
    )
    file_handler.setLevel(level)
    file_handler.setFormatter(formatter)

    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setLevel(level)
    stream_handler.setFormatter(formatter)

    root_logger.addHandler(file_handler)
    root_logger.addHandler(stream_handler)

    # Handle project prefixes to unify logging behavior
    prefixes = log_cfg.project_prefixes
    if prefixes:
        # Check against logging.root.manager.loggerDict safely
        for name, logger_obj in logging.root.manager.loggerDict.items():
            # loggerDict may contain PlaceHolder objects, which are not Loggers
            if not isinstance(logger_obj, logging.Logger):
                continue

            if any(
                name == prefix or name.startswith(f"{prefix}.") for prefix in prefixes
            ):
                logger_obj.setLevel(logging.NOTSET)
                logger_obj.disabled = False
                logger_obj.propagate = True
                logger_obj.handlers.clear()

    root_logger.info("Logging configured. Log file: %s", log_path)

    return root_logger

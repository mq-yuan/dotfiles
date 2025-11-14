import datetime
import logging
import os
import sys
from typing import Optional


def setup_logging(
    log_dir: Optional[str] = None,
    level: int = logging.INFO,
    filemode: str = "w",
):
    """
    Set up the logging system for the entire application.

    Args:
        log_dir (str, optional): The directory to save log files. If None, defaults to "./logs".
        level (int, optional): The logging level. Defaults to logging.INFO. Can also be set via LOG_LEVEL environment variable.
        filemode (str, optional): The file mode for the log file. Defaults to "w".
    """
    if log_dir is None:
        log_dir = "./logs"
    os.makedirs(log_dir, exist_ok=True)

    # Get the name of the main script for the log file
    main_script_name = os.path.basename(sys.argv[0]).replace(".py", "")
    log_file_name = f"{main_script_name}_{datetime.datetime.now().strftime('%Y-%m-%d-%H:%M:%S')}.log"
    log_file_path = os.path.join(log_dir, log_file_name)

    log_format = (
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)"
    )

    # Allow logging level to be overridden by environment variable
    env_level = os.environ.get("LOG_LEVEL")
    if env_level:
        try:
            level = getattr(logging, env_level.upper())
        except AttributeError:
            print(
                f"Warning: Invalid LOG_LEVEL '{env_level}'. Using default level {logging.getLevelName(level)}."
            )

    # Create a logger
    logger = logging.getLogger()
    logger.setLevel(level)

    # Remove existing handlers to avoid duplicate logs if setup_logging is called multiple times
    if logger.hasHandlers():
        logger.handlers.clear()

    # Create handlers
    file_handler = logging.FileHandler(log_file_path, mode=filemode, encoding="utf-8")
    file_handler.setLevel(level)
    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(level)

    # Create formatters and add them to handlers
    formatter = logging.Formatter(log_format)
    file_handler.setFormatter(formatter)
    stream_handler.setFormatter(formatter)

    # Add handlers to the logger
    logger.addHandler(file_handler)
    logger.addHandler(stream_handler)

    logger.info("Logging system configured and started.")
    return logger


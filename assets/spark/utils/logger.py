# Description: class to manage logging for spark applications
# Author: Lotfy Ashmawy

import logging

class Logger:
    def __init__(self, name):
        log_level = logging.INFO
        log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        self.logger = logging.getLogger(name)
        self.logger.setLevel(log_level)
        formatter = logging.Formatter(log_format)
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        self.logger.addHandler(console_handler)
        
    def info(self, message):
        self.logger.info(message)
        
    def warning(self, message):
        self.logger.warning(message)
        
    def error(self, message):
        self.logger.error(message)
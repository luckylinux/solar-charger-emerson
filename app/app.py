# Gracefully Shut Down Application
import signal

# Flask Framework
from flask import Flask

# Logging Tools
from loguru import logger

# Emerson Charger Library
from lib import rectifier

# Core Libraries
import time

# Handle SIGINT and SIGTERM Gracefully within Docker/Podman Containers
# Source: https://stackoverflow.com/a/31464349/2591014
class GracefulKiller:
  kill_now = False
  signals = {
    signal.SIGINT: 'SIGINT',
    signal.SIGTERM: 'SIGTERM'
  }

  def __init__(self):
    signal.signal(signal.SIGINT, self.exit_gracefully)
    signal.signal(signal.SIGTERM, self.exit_gracefully)

  def exit_gracefully(self, signum, frame):
    print("\nReceived {} signal".format(self.signals[signum]))
    print("Cleaning up resources. End of the program")
    self.kill_now = True


# Create Flash App
app = Flask(__name__)

# Define Routes
@app.route('/')
def hello_world():
    return 'Hello, Docker!'


# Main
if __name__ == "__main__":
    # Init GracefulKiller
    killer = GracefulKiller()

    # Configure Logging - Defaults to WARNING
    logLevel = os.getenv('LOG_LEVEL' , 'WARNING')


    # Run the Flask application
    app.run(host="0.0.0.0", port=5000)

    # Infinite loop to prevent the application / Docker container from quitting
    # Exit Application in case of SIGINT or SIGTERM
    while not killer.kill_now:
        # Wait 5 seconds
        time.sleep(5.0)

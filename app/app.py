import signal
import time
from flask import Flask


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

    # Run the Flask application
    app.run(host="0.0.0.0", port=5000)

    # Infinite loop to prevent the application / Docker container from quitting
    while not killer.kill_now:
        # Wait 1 second
        time.sleep(1.0)

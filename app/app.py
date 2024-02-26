import time
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Docker!'


if __name__ == "__main__":
    # Run the Flask application
    app.run(host="0.0.0.0", port=5000)

    # Infinite loop to prevent the application / Docker container from quitting
    while True:
        # Wait 1 second
        time.sleep(1.0)

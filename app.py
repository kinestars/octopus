from flask import Flask, jsonify, request
import os
from pathlib import Path

# env_config = dotenv_values(".env") 
# Init Flask App
basedir = os.path.abspath(os.path.dirname(__file__))

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'my_precious_secret_key')
    DEBUG = False


class DevelopmentConfig(Config):
    DEBUG = True


def create_app(config_name: str) -> Flask:
    app = Flask(__name__)
    app.config.from_object(DevelopmentConfig)
    return app
app = create_app("dev")


# Process Function
DATA_PATH = '/input'
OUTPUT_OBJ_PATH = '/output'

def get_img_name(url):
    return url.split("?")[0].split("/")[-1]

def create_folder_if_not_exist(user_id):
    input_folder = "{}/{}/frames".format(DATA_PATH, user_id)
    output_folder = "{}/{}/".format(OUTPUT_OBJ_PATH, user_id)
    Path(input_folder).mkdir(parents=True, exist_ok=True)
    Path(output_folder).mkdir(parents=True, exist_ok=True)
    return input_folder, output_folder

def generate_pkl(user_id):
    input_folder, _ = create_folder_if_not_exist(user_id)
    try:
        # Run 
        os.system(
            # f"bash run_demo.sh"
            f"echo 'Run Octopus'"
        )
        return True
    except Exception as e:
        print(e)


# API Controller
@app.route('/<int:user_id>', methods=['GET'])
def run_octopus(user_id):
    # user_id = body.get("user_id", None)
    try:
        if not user_id:
            return dict(message="Body should provide user_id"), 400
        is_generate = generate_pkl(user_id=user_id)
        return jsonify(dict(is_generated=is_generate, user_id=user_id))
    except Exception as e:
        return dict(message="Something error", error=str(e)), 500


# Start App
if __name__ == "__main__":
    app.run(host="0.0.0.0" , port=5003) 

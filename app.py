from flask import Flask, request, jsonify
import h5py

app = Flask(__name__)

# Load the model
def load_model():
    tours = {}
    with h5py.File('assets/model/tours.h5', 'r') as h5file:
        for tour_name in h5file.keys():
            group = h5file[tour_name]
            route = list(group['route'])
            weight = group['weight'][()]
            tours[tour_name] = {'route': route, 'weight': weight}
    return tours

# Load the tours data
tours = load_model()

@app.route('/')
def home():
    return "Welcome to the Path Detection API!"

@app.route('/tours', methods=['GET'])
def get_tours():
    return jsonify(tours)

@app.route('/tour/<name>', methods=['GET'])
def get_tour(name):
    if name in tours:
        return jsonify(tours[name])
    else:
        return jsonify({"error": "Tour not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000 ,debug=True)

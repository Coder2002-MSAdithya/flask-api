from flask import Flask, request

app = Flask(__name__)

stores = [
    {
        "name": "Big Bazaar",
        "items": [
            {
                "name": "Chair",
                "price": "15"
            }
        ]
    }
]

@app.get("/health")
def get_health():
    return {"status": "healthy", "version": "1.0.0"}

@app.get("/store")
def get_stores():
    return {"stores": stores}

@app.post("/store")
def create_store():
    request_data = request.get_json()
    stores.append({"name": request_data["name"], "items": []})
    return request_data, 201

@app.post("/store/<string:name>/item")
def create_item(name):
    request_data = request.get_json()
    for store in stores:
        if store["name"] == name:
            store["items"].append({"name" : request_data["name"], "price" : request_data["price"]})
            return request_data, 201
    return {"message" : "Store NOT found"}, 404

@app.get("/store/<string:name>/item")
def get_items_for_store(name):
    for store in stores:
        if store["name"] == name:
            return {"items" : store["items"]}, 201
    return {"message" : "Store NOT found"}, 404
        
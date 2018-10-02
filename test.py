import requests
r = requests.post(
    url = 'http://localhost:8888/upload',
    files = {
        'pic1': open('package.png', 'rb'),
        'pic2': open('package.png', 'rb'),
        'pic3': open('package.png', 'rb'),
        'pic4': open('package.png', 'rb'),
    },
    stream = True,
)
r.raise_for_status()
if r.headers['content-type'] != "image/png":
    raise Exception("Not a PNG")
with open("test.jpg", "wb") as f:
    f.write(r.raw.read())

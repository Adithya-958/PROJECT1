# # from flask import Flask, request, send_file, render_template
# # from pdf2image import convert_from_path
# # import os

# # app = Flask(__name__)

# # # Ensure a folder for storing temporary files
# # TEMP_FOLDER = r"C:\PROJECT1"
# # os.makedirs(TEMP_FOLDER, exist_ok=True)

# # @app.route("/")
# # def index():
# #     return render_template("index.html")

# # @app.route("/convert", methods=["POST"])
# # def convert_pdf():
# #     # Get uploaded file
# #     uploaded_file = request.files["file"]
# #     if uploaded_file.filename.endswith(".pdf"):
# #         # Save the uploaded PDF
# #         pdf_path = os.path.join(TEMP_FOLDER, uploaded_file.filename)
# #         pdf_path = r'C:\PROJECT1\temp_files'
# #         uploaded_file.save(pdf_path)

# #         # Convert PDF to images
# #         images = convert_from_path(pdf_path)
# #         image_files = []
# #         for i, img in enumerate(images):
# #             image_path = os.path.join(TEMP_FOLDER, f"page_{i+1}.jpg")
# #             img.save(image_path, "JPEG")
# #             image_files.append(image_path)

# #         # Prepare a single image to download (for simplicity)
# #         return send_file(image_files[0], as_attachment=True)

# #     return "Invalid file format. Please upload a PDF."

# # if __name__ == "__main__":
# #     app.run(debug=True)


from flask import Flask, request, send_file, render_template
from pdf2image import convert_from_path
import os

app = Flask(__name__)

# Directory for storing temporary files
TEMP_FOLDER = "temp_files"
os.makedirs(TEMP_FOLDER, exist_ok=True)  # Ensure the folder exists

@app.route("/")
def index():
    # Render the HTML form (ensure the file is in 'templates' folder)
    return render_template("index.html")

@app.route("/convert", methods=["POST"])
def convert_pdf():
    # Get the uploaded file
    uploaded_file = request.files["file"]
    if uploaded_file and uploaded_file.filename.endswith(".pdf"):
        # Save the PDF file to the temporary folder
        pdf_path = os.path.join(TEMP_FOLDER, uploaded_file.filename)
        uploaded_file.save(pdf_path)

        #Convert the PDF to JPG images
        try:
            images = convert_from_path(pdf_path)
            image_path = os.path.join(TEMP_FOLDER, uploaded_file.filename+"_converted.jpg")
            images[0].save(image_path, "JPEG")  # Save only the first page as a sample

            # Serve the converted image for download
            return send_file(image_path, as_attachment=True)

        except Exception as e:
            return f"Error during conversion: {e}"

    return "Please upload a valid PDF file."

if __name__ == "__main__":
    app.run(debug=True)

# from flask import Flask

# app = Flask(__name__)

# @app.route('/')
# def home():
#     return "Hello, Flask!"
# from flask import Flask, request, send_file, render_template
# from pdf2image import convert_from_path
# import os

# app = Flask(__name__)

# # Directory for storing temporary files
# TEMP_FOLDER = "temp_files"
# os.makedirs(TEMP_FOLDER, exist_ok=True)  # Ensure the folder exists

# @app.route("/")
# def index():
#     # Render the HTML form (ensure the file is in 'templates' folder)
#     return render_template("index.html")

# @app.route("/convert", methods=["POST"])
# def convert_pdf():
#     # Get the uploaded file
#     uploaded_file = request.files["file"]
#     if uploaded_file and uploaded_file.filename.endswith(".pdf"):
#         # Save the PDF file to the temporary folder
#         pdf_path = os.path.join(TEMP_FOLDER, uploaded_file.filename)
#         uploaded_file.save(pdf_path)

#         #Convert the PDF to JPG images
#         try:
#             images = convert_from_path(pdf_path)
#             image_path = os.path.join(TEMP_FOLDER, uploaded_file.filename+"_converted.jpg")
#             images[0].save(image_path, "JPEG")  # Save only the first page as a sample

#             # Serve the converted image for download
#             return send_file(image_path, as_attachment=True)

#         except Exception as e:
#             return f"Error during conversion: {e}"

#     return "Please upload a valid PDF file."

# if __name__ == "__main__":
#     app.run(debug=True)

from flask import Flask, request, send_file, render_template
from pdf2image import convert_from_path
from PIL import Image
import os
import zipfile
from PyPDF2 import PdfReader, PdfWriter

app = Flask(__name__)

# Temporary folder for storing uploaded and processed files
TEMP_FOLDER = "temp_files"
os.makedirs(TEMP_FOLDER, exist_ok=True)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/convert", methods=["POST"])
@app.route("/merge", methods=["POST"])
def convert_file():
    uploaded_file = request.files["file"]
    conversion_type = request.form["conversionType"]

    if uploaded_file:
        file_path = os.path.join(TEMP_FOLDER, uploaded_file.filename)
        uploaded_file.save(file_path)

        if conversion_type == "pdf_to_image" and file_path.endswith(".pdf"):
            return convert_pdf_to_images(file_path)
        elif conversion_type == "image_to_pdf" and file_path.endswith((".jpg", ".jpeg", ".png")):
            return convert_images_to_pdf(file_path)
        else:
            return "Invalid file type for the selected conversion.", 400

    return "No file uploaded.", 400

# def convert_pdf_to_images(pdf_path):
#     try:
#         # Convert all pages of the PDF to images
#         images = convert_from_path(pdf_path)
#         image_paths = []
        
#         for i, img in enumerate(images):
#             image_path = os.path.join(TEMP_FOLDER, f"page_{i + 1}.jpg")
#             img.save(image_path, "JPEG")
#             image_paths.append(image_path)

#         # Create a ZIP file containing all the images
#         zip_path = os.path.join(TEMP_FOLDER, "converted_images.zip")
#         with zipfile.ZipFile(zip_path, "w") as zipf:
#             for image in image_paths:
#                 zipf.write(image, os.path.basename(image))
        
#         return send_file(zip_path, as_attachment=True)
#     except Exception as e:
#         return f"Error during conversion: {e}", 500

def convert_pdf_to_images(pdf_path):
    try:
        # Convert all pages of the PDF to images
        images = convert_from_path(pdf_path)
        image_paths = []
        
        for i, img in enumerate(images):
            image_path = os.path.join(TEMP_FOLDER, f"page_{i + 1}.jpg")
            img.save(image_path, "JPEG")
            image_paths.append(image_path)

        # Check if the PDF has more than 1 page
        if len(images) == 1:
            # Return the single image file directly
            return send_file(image_paths[0], as_attachment=True)
        else:
            # Create a ZIP file containing all the images
            zip_path = os.path.join(TEMP_FOLDER, "converted_images.zip")
            with zipfile.ZipFile(zip_path, "w") as zipf:
                for image in image_paths:
                    zipf.write(image, os.path.basename(image))
            return send_file(zip_path, as_attachment=True)

    except Exception as e:
        return f"Error during conversion: {e}", 500

def convert_images_to_pdf(image_path):
    try:
        # Load the image and convert it to a single PDF
        image = Image.open(image_path).convert("RGB")
        pdf_path = os.path.join(TEMP_FOLDER, "converted_file.pdf")
        image.save(pdf_path, "PDF", resolution=100.0)
        return send_file(pdf_path, as_attachment=True)
    except Exception as e:
        return f"Error during conversion: {e}", 500

def merge_pdfs():
    try:
        # Get the uploaded files
        file1 = request.files["file1"]
        file2 = request.files["file2"]

        if file1 and file2 and file1.filename.endswith(".pdf") and file2.filename.endswith(".pdf"):
            # Save the uploaded files to the temporary folder
            file1_path = os.path.join(TEMP_FOLDER, file1.filename)
            file2_path = os.path.join(TEMP_FOLDER, file2.filename)
            file1.save(file1_path)
            file2.save(file2_path)

            # Merge PDFs
            merged_pdf_path = os.path.join(TEMP_FOLDER, file1.filename_file2.filename+"merged.pdf")
            pdf_writer = PdfWriter()

            for pdf_path in [file1_path, file2_path]:
                pdf_reader = PdfReader(pdf_path)
                for page in pdf_reader.pages:
                    pdf_writer.add_page(page)

            with open(merged_pdf_path, "wb") as merged_file:
                pdf_writer.write(merged_file)

            # Serve the merged PDF for download
            return send_file(merged_pdf_path, as_attachment=True)

        return "Invalid files. Please upload valid PDF files.", 400

    except Exception as e:
        return f"Error during merging: {e}", 500

if __name__ == "__main__":
    app.run(debug=True)
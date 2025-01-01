# Use the official Python image from the Docker Hub
FROM python:3.12

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Install the dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Set the entry point for the Lambda function
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]

# Specify the command to run your handler
CMD ["lambda_function.handler"]

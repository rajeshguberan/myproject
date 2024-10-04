provider "aws" {
  region = "us-east-1" # Change to your preferred region
}
 
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP traffic"
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "my_instance" {
  ami           = "ami-0a0e5d9c7acc336f1" # Ubuntu Server 22.04 LTS
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
 
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y python3-pip
              sudo pip3 install flask
 
              cat << 'EOL' > /home/ubuntu/app.py
              from flask import Flask
              app = Flask(__name__)
 
              @app.route('/')
              def hello():
                  return '<html><h1>Hello, World from Flask!</h1></html>'
 
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOL
 
              # Run the Flask app in the background
              sudo nohup python3 /home/ubuntu/app.py &
              EOF
 
  tags = {
    Name = "MyFlaskInstance"
  }

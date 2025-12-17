provider "aws" {
  region = "eu-central-1"  # Change to your desired region
}

resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatars-tabe1"

  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}


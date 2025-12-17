resource "aws_s3_bucket" "avatars"{
  bucket = "grocerymate-avatars-tabe"

  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}

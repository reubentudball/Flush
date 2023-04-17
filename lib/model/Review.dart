

class Review{
  String cleanliness = "";
  String traffic = "";
  String size = "";
  String feedback = "";
  bool accessibility = true;
  bool isFavorite = true;

  Review();
  Review.create(this.cleanliness,this.traffic, this.size,this.feedback,this.accessibility);



  void reviewDesc(){
    print("$cleanliness, $traffic, $size,$feedback,$accessibility");
  }
}
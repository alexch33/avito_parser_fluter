class Ad {
  int id;
  String url;
  String title;
  String description;
  String time;
  String price;

  Ad(
      {required this.id,
      required this.url,
      required this.title,
      required this.description,
      required this.time,
      required this.price});

  factory Ad.fromMap(Map<String, dynamic> json) => Ad(
      id: json["id"],
      url: json["url"],
      title: json["title"],
      description: json["description"],
      price: json["price"],
      time: json["time"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "url": url,
        "title": title,
        "description": description,
        "time": time,
        "price": price
      };

  @override
  String toString() {
    return "id: $id url: $url title: $title description: $description time: $time price: $price";
  }
}

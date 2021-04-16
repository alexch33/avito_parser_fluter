class Ad {
  int id;
  String url;
  String title;
  String description;
  String time;

  Ad({this.id, this.url, this.title, this.description, this.time});

  factory Ad.fromMap(Map<String, dynamic> json) => Ad(
      id: json["id"],
      url: json["url"],
      title: json["title"],
      description: json["description"],
      time: json["time"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "url": url,
        "title": title,
        "description": description,
        "time": time
      };
}

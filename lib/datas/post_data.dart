class Post {
  int id, viewCount, authorID;
  String title, description, date, authorName, expireDate, phone, timeAgo;
  bool isFavorite;

  Post(
      this.id,
      this.title,
      this.description,
      this.date,
      this.viewCount,
      this.authorID,
      this.authorName,
      this.expireDate,
      this.phone,
      this.timeAgo,
      this.isFavorite);
}

class MyPost {
  int id, viewCount;
  String title, description, date, status, statusText, phone, timeAgo;

  MyPost(this.id, this.title, this.description, this.date, this.viewCount,
      this.status, this.statusText, this.phone, this.timeAgo);
}

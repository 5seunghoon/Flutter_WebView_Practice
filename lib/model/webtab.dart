class WebTab {
  int id;
  String url;

  WebTab(this.id, this.url);

  String get getTabIdToThreeWords {
    if(id < 10) return "00" + id.toString();
    else if(id < 100) return "0" + id.toString();
    else return id.toString();
  }
}
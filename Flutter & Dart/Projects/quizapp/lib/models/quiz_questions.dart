class Questions {
  const Questions(this.text, this.answers);

  final String text;
  final List<String> answers;

  List<String> getShuffledAnswers() {
    final shuffelList = List.of(answers);
    shuffelList.shuffle();
    return shuffelList;
  }
}

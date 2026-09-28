enum Gender {
  male(value: 'MALE', label: '남자'),
  female(value: 'FEMALE', label: '여자');

  final String value;
  final String label;

  const Gender({required this.value, required this.label});

  factory Gender.getString(String? value) {
    switch (value?.toUpperCase()) {
      case 'WOMAN':
      case 'FEMALE':
        return Gender.female;
      case 'MAN':
      case 'MALE':
      default:
        return Gender.male;
    }
  }
}

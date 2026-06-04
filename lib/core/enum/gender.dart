enum Gender {
  male(value: 'MALE', ko: '남자'),
  female(value: 'FEMALE', ko: '여자');

  final String value;
  final String ko;

  const Gender({required this.value, required this.ko});
}

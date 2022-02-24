abstract class IValidator<T> {
  T? validate(T? obj);
  const IValidator();
}

class EmptyStringValidator extends IValidator<String> {
  final String fieldName;

  const EmptyStringValidator(this.fieldName);
  @override
  String? validate(String? obj) {
    return obj != null && obj.isNotEmpty ? null : '$fieldName Can\'t be empty';
  }
}

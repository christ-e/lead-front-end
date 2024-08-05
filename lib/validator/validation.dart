class ErrorValidation {
  loginUsername(value) {
    if (value.isEmpty) {
      return "Please enter your Email";
    }
    if (!value.contains("@gmail.com")) {
      return "Enter Valid Gmail Address";
    }
    return null;
  }

  loginPassword(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return "Enter Valid Password\nPassword has 6 Letters";
    }
    return null;
  }
  //create user

  createUsername(value) {
    if (value.isEmpty) {
      return "Please enter your Email";
    }
    if (!value.contains("@gmail.com")) {
      return "Enter Valid Gmail Address";
    }
    return null;
  }

  createName(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  createPassword(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return "Password have atlest 6 Letters";
    }
    return null;
  }

  String? createPhoneNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (value.length < 10) {
      return "Enter a valid phone number\nEnter 10 digit number";
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return "Enter a valid phone number\nPhone number should only contain digits";
    }
    return null;
  }
}

class Message {
  Message({
    required this.toId,
    required this.formId,
    required this.msg,
    required this.read,
    required this.type,
    required this.sent,
  });
  late final String toId;
  late final String formId;
  late final String msg;
  late final String read;
  late final String sent;
  late final Type type;
  
  Message.fromJson(Map<String, dynamic> json){
    toId = json['toId'].toString();
    formId = json['formId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    //type = json['type'].toString() == Type.image.name? Type.image : Type.text;
      if (json['type'].toString() == Type.image.name) {
    type = Type.image;
  } else if (json['type'].toString() == Type.pdf.name) {
    type = Type.pdf;
  } else {
    type = Type.text;
  }
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['formId'] = formId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}
enum Type{text, image, pdf}
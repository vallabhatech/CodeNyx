const adminEmails = [
  "kawshikkshriidatta@gmail.com",
  "kawshikk.512@gmail.com",
  "krishnakireetiog@gmail.com",
  "thanusree12075@gmail.com",
  "achi.samrat@gmail.com",
  "ranabothuvarshithareddy@gmail.com",
  "chinkusavanth@gmail.com",
  "sreejassadhu@gmail.com",
  "eswardudi06@gmail.com",
  "krishnakondi2006@gmail.com",
  "umaranig2006@gmail.com",
  "enjamurimanuha@gmail.com",
  "nimmagaddatrishikesh@gmail.com",
  "shaiksiddiq264@gmail.com",
  "mksathvik03@gmail.com",
  "nv181206@gmail.com",
  "tejasvvisarvasiddi@gmail.com",
  "shashankreddy9848@gmail.com",
  "vijayamaresh16@gmail.com",
  "agandlarishitha@gmail.com",
  "manupalash4@gmail.com",
];


bool isAdminUser(String? email) {
  if (email == null) return false;

  final normalizedEmail = email.trim().toLowerCase();
  return adminEmails.contains(normalizedEmail);
}

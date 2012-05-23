function (doc) {
  doc.authors.forEach(function(author){
    emit([author.name.charAt(0).toLowerCase(), author.name], null);
  });
}
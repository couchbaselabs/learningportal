function (doc) {
  doc.authors.forEach(function(author){
    emit([author.name, doc._id], null)
  });
}
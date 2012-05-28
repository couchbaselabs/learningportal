function (doc) {
  doc.categories.forEach(function(category){
    emit([category, doc._id], null)
  });
}
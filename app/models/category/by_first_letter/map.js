function (doc) {
  doc.categories.forEach(function(category){
    emit([category.charAt(0).toLowerCase(), category], null);
  });
}
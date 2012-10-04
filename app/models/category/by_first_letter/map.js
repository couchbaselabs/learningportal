function (doc, meta) {
  if (doc.type){
    doc.categories.forEach(function(category){
      emit([category.charAt(0).toLowerCase(), category], null);
    });
  }
}
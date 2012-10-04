function (doc, meta) {
  if (doc.type){
    doc.categories.forEach(function(category){
      emit([category, meta.id], null)
    });
  }
}
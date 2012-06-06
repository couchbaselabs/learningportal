function (doc) {
  if (doc.type){
    doc.categories.forEach(function(category){
      emit([category, doc._id], null)
    });
  }
}
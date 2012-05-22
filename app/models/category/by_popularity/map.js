function(doc){
  doc.categories.forEach(function(category){
    emit(category, null);
  });
}
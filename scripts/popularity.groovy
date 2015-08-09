if (doc.containsKey('popularity')) { 
  return log10(doc['popularity'].value +1)
} else {
  return 0
}
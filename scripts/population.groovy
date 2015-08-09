if (doc.containsKey('population')) { 
  return log10(doc['population'].value +1)
} else {
  return 0
}
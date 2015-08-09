// expects category_weights passed in with weight mapping
if (doc.containsKey('category')) {
  score = 0
  categories = doc['category'].values
  categories.each { category ->
    if(category in category_weights){
      score += category_weights[category]
    }
  }
  return score
} else {
  return 0
}

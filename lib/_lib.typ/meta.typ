/// meta data management for documents

#import "./meta/categories.typ": categories, register-category, update-category
#import "./meta/tags.typ": tags, update-tags
#import "./meta/share.typ": share, update-share
#import "meta/indexer.typ": index, indexers, register-indexer
#import "./meta/docs.typ": documents
#import "./meta/uids.typ": nid
#import "./meta/current.typ": current

#import "./util.typ": repri


/// - shared meta data for documents
#let meta = (
  categories: categories,
  tags: tags,
  indexers: indexers,
  documents: documents,
  share: share,
  current: current,
)

/// - n (str | none): which meta data querying
/// -> any
#let fetch-meta(n: none) = {
  if n == none {
    meta.current.get()
  } else {
    meta.at(n).get()
  }
}

/// - title (str): document title
/// - author (str | array[str]): authors
/// - date (datetime): time when document created
/// - keywords (array[str]): keywords for document
/// - id (str): id for current document
/// - parent_id (str): parent document
/// - description (str): simple description for current document
/// - category (str): category
/// - tag (array[str]): tags
/// - abstract (content): abstract for current document
/// - tbl (dict): any attributes
/// -> none
#let meta(
  title: none,
  author: none,
  date: datetime.today(),
  keywords: (),
  id: "",
  parent_id: none,
  description: none,
  category: none,
  tag: (),
  abstract: [],
  tbl: none,
) = {
  assert.eq(type(title), str)
  assert({
    let t = type(author)
    t == array or t == content
  })
  assert.eq(type(date), datetime)
  let compdate = datetime.today()
  assert(type(keywords) == array or keywords == str)
  assert.eq(type(id), str)
  if parent_id == none {
    parent_id = id
  }
  assert.eq(type(parent_id), str)
  assert({
    let t = type(tbl)
    (t == dictionary or tbl == none)
  })
  assert(type(description) == content or description == none)
  assert(type(category) == str or category == none)
  assert.eq(type(tag), array)
  assert.eq(type(abstract), content)

  let idx = id + "-" + category + "--" + repri(title)
  assert.eq(type(idx), str)
  let doc = (
    title: title,
    author: author,
    date: date,
    keywords: keywords,
    id: id,
    uid: nid(),
    parent_id: parent_id,
    description: description,
    category: category,
    tag: tag,
    abstract: abstract,
    ..tbl,
  )
  documents.update(prev => (
    ..prev,
    (idx): doc,
  ))
  if category != none {
    update-category(category, idx)
  }
  for t in tag {
    update-tags(t, idx)
  }
  current.update(prev => ((idx): doc))
}

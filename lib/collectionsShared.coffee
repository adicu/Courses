@CollectionsShared =
  createdAt:
    type: Date
    autoValue: ->
      if @isInsert
        return new Date()
      else if @isUpsert
        return $setOnInsert: new Date()
      else
        @unset()

    denyUpdate: true

  updatedAt:
    type: Date,
    autoValue: ->
      if @isUpdate
        return new Date()
    denyInsert: true,
    optional: true

  owner:
    type: String
    autoValue: ->
      if @isInsert
        return @userId
      else if @isUpsert
        return $setOnInsert: @userId
      else
        @unset()
    denyUpdate: true
    index: 1

$ = jQuery

class Task extends Spine.Model
  @configure "Task", "name", "done"
  
  @extend Spine.Model.Local

  @active: ->
    @select (item) -> !item.done

  @done: ->
    @select (item) -> !!item.done

  @destroyDone: ->
    rec.destroy() for rec in @done()

class Tasks extends Spine.Controller
  tag: "li"
    
  events:
   "change   input[type=checkbox]": "toggle"
   "click    .destroy":             "destroy"
   "dblclick .view":                "edit"
   "keypress input[type=text]":     "blurOnEnter"
   "blur     input[type=text]":     "close"
 
  elements:
    "input[type=text]": "input"
    ".item": "wrapper"

  constructor: ->
    super
    @item.bind("update",  @render)
    @item.bind("destroy", @remove)
  
  render: =>
    @html($("#taskTemplate").tmpl(@item))
    @
  
  toggle: ->
    @item.done = !@item.done
    @item.save()
  
  destroy: ->
    @item.destroy()
  
  edit: ->
    @wrapper.addClass("editing")
    @input.focus()
  
  blurOnEnter: (e) ->
    if e.keyCode == 13 then e.target.blur()
  
  close: ->
    @wrapper.removeClass("editing")
    @item.updateAttributes({name: @input.val()})
  
  remove: =>
    @el.remove()

class TaskApp extends Spine.Controller
  events:
    "submit form":   "create"
    "click  .clear": "clear"

  elements:
    ".items":     "items"
    ".countVal":  "count"
    ".clear":     "clear"
    "form input": "input"
  
  constructor: ->
    super
    Task.bind("create",  @addOne)
    Task.bind("refresh", @addAll)
    Task.bind("refresh change", @renderCount)
    Task.fetch()
  
  addOne: (task) =>
    view = new Tasks(item: task)
    @items.append(view.render().el)
  
  addAll: =>
    Task.each(@addOne)

  create: (e) ->
    e.preventDefault()
    Task.create(name: @input.val())
    @input.val("")
  
  clear: ->
    Task.destroyDone()
  
  renderCount: =>
    active = Task.active().length
    @count.text(active)
    
    inactive = Task.done().length
    if inactive 
      @clear.show()
    else
      @clear.hide()

$ ->
  new TaskApp(el: $("#tasks"))
roga.animation = {}
roga.animation.animationManager =
  initialize: (root) ->
    @root = root
    @instances = []

  start: (animation) ->
    @instances.push animation
    @root.addChild animation.node
    animation.interval.start()

  update: ->
    i = @instances.length - 1

    while i >= 0
      instance = @instances[i]
      instance.interval.update()
      if instance.interval.isDone()
        @root.removeChild instance.node
        @instances.splice i, 1
      i--

  CreateAnimation: (data, isSubAnimation, baseTransform, baseAlpha, basePriority, target) ->
    timelines = data["timelines"]
    parallels = []
    node = new roga.canvas.Node(baseTransform)
    node.setAlpha baseAlpha
    node.setPriority  basePriority

    for timelineNo of timelines
      timeline = timelines[timelineNo]
      sprite = new roga.canvas.Sprite()
      sequences = []
      attributes = [ "alpha", "scale", "position", "rotation" ]
      for i of attributes
        attribute = attributes[i]
        sequence = roga.animation.animationManager.CreateAttributeTween(sprite, attribute, timeline[attribute], target)
        sequences.push sequence  if sequence
      sourceInterval = new roga.animation.interval.SourceInterval(sprite, timeline["source"], target)
      sequences.push sourceInterval
      parallels.push new roga.animation.interval.Parallel(sequences)
      node.addChild sprite

    parallelInterval = new roga.animation.interval.Parallel(parallels)
    interval = null
    if isSubAnimation
      interval = new roga.animation.interval.Loop(parallelInterval, 0)
    else
      interval = parallelInterval
    
    {interval: interval, node: node}

  CreateAttributeTween: (node, attribute, keyframes, target) ->
    if keyframes.length is 0
      null
    else
      intervals = []
      i = 0

      while i < keyframes.length
        frame = keyframes[i]
        tween = frame.tween
        interval = null
        if frame.wait
          duration = frame.duration
          interval = new roga.animation.interval.Wait(duration)
        else
          startValue = frame.startValue
          endValue = frame.endValue
          duration = frame.duration
          options = {}
          if attribute is "position"
            options.startPositionAnchor = frame.startPositionAnchor
            options.endPositionAnchor = frame.endPositionAnchor
            options.startPositionType = frame.startPositionType
            options.endPositionType = frame.endPositionType
            options.target = target
          else if attribute is "rotation"
            options.facingOption = frame.facingOption
            options.target = target
          interval = new roga.animation.interval.AttributeInterval(node, attribute, startValue, endValue, duration, tween, options)
        intervals.push interval
        i++
      new roga.animation.interval.Sequence(intervals)

roga.animation.interval =
  Completement: (startValue, endValue, proportion) ->
    result = null
    if typeof (startValue) is "number"
      result = startValue + (endValue - startValue) * proportion
    else if typeof (startValue) is "object"
      result = []
      i = 0

      while i < startValue.length
        value = startValue[i] + (endValue[i] - startValue[i]) * proportion
        result.push value
        i++
    result

  _GetRelativePosition: (node, target, positionType, positionAnchor, offset) ->
    result = offset
    if positionType is "relativeToTarget"
      anchorOffset = target.node.getOffsetByPositionAnchor(positionAnchor)
      tempPos = [ target.node.getPosition()[0], target.node.getPosition()[1] ]
      tempPos[0] = tempPos[0] + offset[0] + anchorOffset[0]
      tempPos[1] = tempPos[1] + offset[1] + anchorOffset[1]
      targetPosition = roga.matrix.transformPoint(tempPos, target.node.getParent().getTransform())
      invertMatrix = roga.matrix.createInverseMatrix(node.getParent().getTransform(), 3)
      result = roga.matrix.transformPoint(targetPosition, invertMatrix)
    else if positionType is "relativeToTargetOrigin"
      anchorOffset = target.node.getOffsetByPositionAnchor(positionAnchor)
      tempPos = [ target.origin[0], target.origin[1] ]
      tempPos[0] = tempPos[0] + offset[0] + anchorOffset[0]
      tempPos[1] = tempPos[1] + offset[1] + anchorOffset[1]
      targetPosition = roga.matrix.transformPoint(tempPos, target.node.getParent().getTransform())
      invertMatrix = roga.matrix.createInverseMatrix(node.getParent().getTransform(), 3)
      result = roga.matrix.transformPoint(targetPosition, invertMatrix)
    result

  CalculateRelativePosition: (startValue, endValue, node, startPositionType, endPositionType, startPositionAnchor, endPositionAnchor, target) ->
    resultStartValue = startValue
    resultEndValue = endValue
    if target and node.getParent()
      resultStartValue = @_GetRelativePosition(node, target, startPositionType, startPositionAnchor, startValue)
      resultEndValue = @_GetRelativePosition(node, target, endPositionType, endPositionAnchor, endValue)
    [ resultStartValue, resultEndValue ]

  CalculateDynamicRotation: (startValue, endValue, node, facingOption, target, dataStore) ->
    if target
      invertMatrix = null
      if facingOption is "faceToDir"
        absStartPosition = undefined
        absTargetPosition = undefined
        if node.getParent()
          absStartPosition = roga.matrix.transformPoint(node.getPosition(), node.getParent().getTransform())
          absTargetPosition = roga.matrix.transformPoint(target.node.getPosition(), node.getParent().getTransform())
        else
          absStartPosition = node.getPosition()
          absTargetPosition = target.node.getPosition()
        dx = absTargetPosition[0] - absStartPosition.getPosition()[0]
        dy = absTargetPosition[1] - absStartPosition.getPosition()[1]
        startValue = (Math.atan2(dy, dx) / Math.PI) * 180
        endValue = startValue
      else if facingOption is "faceToMov"
        absStartPosition = (if dataStore.lastAbsPosition then dataStore.lastAbsPosition else [ 0, 0 ])
        absTargetPosition = node.getPosition()
        absTargetPosition = roga.matrix.transformPoint(node.getPosition(), node.getParent().getTransform())  if node.getParent()
        dx = absTargetPosition[0] - absStartPosition[0]
        dy = absTargetPosition[1] - absStartPosition[1]
        startValue += (Math.atan2(dy, dx) / Math.PI) * 180
        endValue = startValue
        if dataStore.ignore
          node.getParent().setAlpha dataStore.lastAlpha
        else
          dataStore.ignore = true
          dataStore.lastAlpha = node.getParent().getAlpha()
          node.getParent().setAlpha 0
        dataStore.lastAbsPosition = absTargetPosition
    [ startValue, endValue ]

  CalculateAttributeValues: (attribute, startValue, endValue, node, options, dataStore) ->
    result = null
    if attribute is "position"
      result = roga.animation.interval.CalculateRelativePosition(startValue, endValue, node, options.startPositionType, options.endPositionType, options.startPositionAnchor, options.endPositionAnchor, options.target)
    else result = roga.animation.interval.CalculateDynamicRotation(startValue, endValue, node, options.facingOption, options.target, dataStore)  if attribute is "rotation"
    result

@module "roga.animation.interval", ->
  class @AttributeInterval
    constructor: (node, attribute, startValue, endValue, duration, tween, options) ->
      @_node = node
      @_startValue = startValue
      @_endValue = endValue
      @_duration = duration
      @_attribute = attribute
      @_frameNo = 0
      @_tween = tween
      @_dataStore = {}
      @_options = options
  
    isDone: ->
      @_frameNo >= @_duration
  
    reset: ->
      @_frameNo = 0
      @start()
  
    start: ->
      @_node.setAttribute @_attribute, @_startValue
      @_frameNo = 0
      @updateValue()
  
    finish: ->
  
    updateValue: ->
      startValue = @_startValue
      endValue = @_endValue
      result = roga.animation.interval.CalculateAttributeValues(@_attribute, @_startValue, @_endValue, @_node, @_options, @_dataStore)
      if result
        startValue = result[0]
        endValue = result[1]
      value = startValue
      value = roga.animation.interval.Completement(startValue, endValue, @_frameNo / @_duration)  if @_tween
      @_node.setAttribute @_attribute, value
  
    update: ->
      unless @isDone()
        @_frameNo++
        @updateValue()
  
  class @Wait
        constructor: (duration) ->
          @_duration = duration
          @_frameNo = 0
      
        isDone: ->
          @_frameNo >= @_duration
      
        reset: ->
          @_frameNo = 0
          @start()
      
        start: ->
          @_frameNo = 0
      
        finish: ->
      
        update: ->
          @_frameNo++  unless @isDone()
  
  class @SourceInterval
        constructor: (sprite, sourceKeykeyframes, target) ->
          @_sprite = sprite
          @_interval = null
          @_sourceKeykeyframes = roga.Helper.instance().clone(sourceKeykeyframes)
          @_frameNo = 0
          @_index = 0
          @_frameDuration = 0
          @_duration = 0
          @_target = target
          @_lastAnimationId = ""
          for key of @_sourceKeykeyframes
            @_duration += @_sourceKeykeyframes[key].duration
      
        isDone: ->
          @_frameNo >= @_duration
      
        _clearSetting: ->
          @_sprite.setSrcRect null
          @_sprite.setSrcPath null
          if @_interval
            @_interval = null
            @_sprite.removeAllChildren()
      
        _updateKeyframe: (keyframe) ->
          @_clearSetting()  unless @_lastAnimationId is keyframe.id
          @_lastAnimationId = keyframe.id
          @_sprite.setPriority (keyframe.priority || 0.5)
          @_sprite.setBlendType (keyframe.blendType || "none")
          if keyframe.type is "image"
            @_sprite.setSrcPath keyframe.id + ".png"
            @_sprite.setSrcRect  keyframe.rect
            @_sprite.setCenter keyframe.center
          else
            if @_interval
              @_interval.update()
            else
              if keyframe.emitter
                transform = null
                if @_sprite.getParent()
                  transform = @_sprite.getParent().getTransform()
                  transform = roga.matrix.getNodeTransformMatirx(@_sprite.getPosition()[0], @_sprite.getPosition()[1], @_sprite.getRotation() * Math.PI / 180, @_sprite.getScale()[0], @_sprite.getScale()[1])
                  transform = roga.matrix.matrixMultiply(transform, @_sprite.getParent().getTransform())
      
                animation = roga.animation.animationManager.CreateAnimation(enchant.loader.getAnimation(keyframe.id), false, transform, @_sprite.getAlpha(), @_sprite.getPriority(), @_target)
                
                if keyframe.maxEmitSpeed > 0
                  speed = keyframe.minEmitSpeed + (keyframe.maxEmitSpeed - keyframe.minEmitSpeed) * Math.random()
                  angle = keyframe.minEmitAngle + (keyframe.maxEmitAngle - keyframe.minEmitAngle) * Math.random()
                  rad = (angle / 180) * Math.PI
                  animation.node.setVelocity [speed * Math.cos(rad), speed * Math.sin(rad)]
                
                roga.animation.animationManager.start animation
      
              else
                if keyframe.id
                  @_sprite.updateTransform()
                  animation = roga.animation.animationManager.CreateAnimation(enchant.loader.getAnimation(keyframe.id), true, null, 1, 0.5, @_target)
                  @_sprite.addChild animation.node
                  @_interval = animation.interval
                  @_interval.start()
      
        reset: ->
          @_frameNo = 0
          @_index = 0
          @_frameDuration = 0
          @_interval.reset()  if @_interval
      
        start: ->
          keyframe = @_sourceKeykeyframes[0]
          @_updateKeyframe keyframe
      
        finish: ->
          @_clearSetting()
      
        update: ->
          if @isDone()
            @_clearSetting()
          else
            @_frameDuration++
            @_frameNo++
            keyframe = @_sourceKeykeyframes[@_index]
            @_updateKeyframe keyframe
            if @_frameDuration >= keyframe.duration
              @_index++
              @_frameDuration = 0
      
  class @Loop
        constructor: (interval, loopCount) ->
          @_loopCounter = 0
          @_loopCount = loopCount
          @_interval = interval
      
        isDone: ->
          _isDone = false
          if @_loopCount is 0
            _isDone = false
          else
            _isDone = @_interval.isDone() and @_loopCounter >= @_loopCount - 1
          _isDone
      
        reset: ->
          @_loopCounter = 0
          @_interval.reset()
      
        start: ->
          @_interval.start()
      
        finish: ->
          @_interval.finish()
      
        update: ->
          unless @isDone()
            @_interval.update()
            if @_interval.isDone()
              @_loopCounter++
              @_interval.reset()  if @_loopCount is 0 or @_loopCounter < @_loopCount
  
  class @Sequence
        constructor: (intervals) ->
          @_intervals = intervals
          @_index = 0
          length = @_intervals.length
          @_lastInterval = @_intervals[length - 1]
      
        isDone: ->
          @_lastInterval.isDone()
      
        reset: ->
          @_index = 0
          for i of @_intervals
            @_intervals[i].reset()
          @start()
      
        start: ->
          @_intervals[0].start()
      
        finish: ->
          @_intervals[@_index].finish()
      
        update: ->
          unless @isDone()
            currentInterval = @_intervals[@_index]
            currentInterval.update()
            if @isDone()
              @finish()
            else @_index++  if currentInterval.isDone()
      
  class @Parallel
        constructor: (intervals) ->
          @_intervals = intervals
      
        isDone: ->
          isDone = true
          for i of @_intervals
            unless @_intervals[i].isDone()
              isDone = false
              break
          isDone
      
        reset: ->
          for i of @_intervals
            @_intervals[i].reset()
          @start()
      
        start: ->
          for i of @_intervals
            @_intervals[i].start()
      
        finish: ->
          for i of @_intervals
            @_intervals[i].finish()
      
        update: ->
          unless @isDone()
            for i of @_intervals
              @_intervals[i].update()
            @finish()  if @isDone()
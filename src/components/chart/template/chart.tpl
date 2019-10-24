<template>
    <div class="chart">
        <vue-draggable-resizable :x="x"
                                 :y="y"
                                 :w="width"
                                 :h="height"
                                 @dragging="(left, top) =>onDrag('<%- config.chartId%>',left,top)"
                                 @resizing="(x, y, width, height) =>onResize('<%- config.chartId%>',x, y, width, height)"
                                 @activated="onActivated('<%- config.chartId%>')">
            <div @click="deleteChart('<%- config.chartId%>')" class="delete">删除</div>
            <div class="chart" ref="<%- config.chartId%>"
                               style="width: <%- config.config.width%>px;height:<%- config.config.height%>px;"
                               data-width="<%- config.config.width%>" data-height="<%- config.config.height%>" data-x="<%- config.config.dx%>" data-y="<%- config.config.dy%>"></div>
        </vue-draggable-resizable>
    </div>
</template>
<script>
    import './chart.styl'
    let echarts = require('echarts')
    import {getChartData} from "api/bar"
    import {getCommonConfig} from "common/js/normalize"
    import {socket} from "common/js/socket-client"
    import jsonobj from "common/js/chalk.project.json"
    import {mapGetters,mapMutations} from 'vuex'
    export default {
        data(){
            return {
                x:0,
                y:0,
                width:10,
                height:10,
                chartId:'<%- config.chartId%>'
            }
        },
        mounted() {
            let mconfig = <%- JSON.stringify(config)%>
            let commonConfig = mconfig.config.commonConfig
            let userConfig = mconfig.config.userConfig
            let dataUrl = mconfig.config.dataUrl
            echarts.registerTheme('chalk',jsonobj)
            this.$echarts = echarts.init(this.$refs.<%- config.chartId%>, 'chalk', {
                width: mconfig.config.width,
                height: mconfig.config.height
            })
            this.$echarts.showLoading('default')
            getChartData(dataUrl).then((res)=>{
                this.$echarts.hideLoading()
                let tempConfig = getCommonConfig(res.data.array,commonConfig,userConfig,<%- config.chartType%>)
                this.$echarts.setOption(tempConfig)
                this.x = mconfig.config.dx
                this.y = mconfig.config.dy
                this.width = mconfig.config.width
                this.height = mconfig.config.height
                this.setPosition({id:'<%- config.chartId%>',x:mconfig.config.dx,y:mconfig.config.dy,width:mconfig.config.width,height:mconfig.config.height})
            })
        },
        computed:{
             ...mapGetters(
                ['storePosition','increaseId']
             )
        },
        watch:{
            increaseId(){
                let pos = this.storePosition(this.chartId)
                if(this.x != pos.x){
                    this.x = pos.x
                }
                if(this.y != pos.y){
                    this.y = pos.y
                }
                if(this.width != pos.width){
                    this.width = pos.width
                    this.$echarts.resize({width:pos.width})
                }
                if(this.height != pos.height){
                    this.height = pos.height
                }
            }
        },
        methods:{
            onDrag(id,x,y){
                let position = {
                   dx:x,
                   dy:y,
                   chartId:id
                }
                this.setPosition({id:this.chartId,x:x,y:y,width:this.width,height:this.height})
                socket.emit('onDragInPanel',JSON.stringify(position))
            },
            onResize(id,x,y,width,height){
               let position = {
                   dx:x,
                   dy:y,
                   width:width,
                   height:height,
                   chartId:id
               }
               this.setPosition({id:this.chartId,x:x,y:y,width:width,height:height})
               this.$echarts.resize({width:width,height:height})
               socket.emit('onDragInPanel',JSON.stringify(position))
            },
            deleteChart(id){
                socket.emit('onDragRemove',id)
            },
            onActivated(id){
                //console.log(this.storePosition(id))
                //let _set = this.$refs[id].dataset
                this.setChartId(id)
                //this.setChartWidth(_set.width)
                //this.setChartHeight(_set.height)
                //this.setChartX(_set.x)
                //this.setChartY(_set.y)
                this.setIncreaseId(this.increaseId+1)
                //this.setPosition({id:id,x:_set.x,y:_set.y,width:_set.width,height:_set.height})
            },
            ...mapMutations({
                setChartId:'SET_CHART_ID',
                setChartWidth:'SET_CHART_WIDTH',
                setChartHeight:'SET_CHART_HEIGHT',
                setChartX:'SET_CHART_X',
                setChartY:'SET_CHART_Y',
                setPosition:'SET_POSITION',
                setIncreaseId:'SET_INCREASE_ID'
            })
        }
    }
</script>
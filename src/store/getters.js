export const chartId = state => state.chartId
export const chartWidth = state => state.chartWidth
export const chartHeight = state => state.chartHeight
export const chartX = state => state.chartX
export const chartY = state => state.chartY
export const storePosition = (state) => (chartId) => state.storePosition[chartId]
export const increaseId = state => state.increaseId
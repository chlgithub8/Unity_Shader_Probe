# Unity_Shader_Probe
描述了一些用shader做的特效，供学习交流使用。

Swing：增加一个顶点动画，每个顶点随机摇摆，作为背景使用。

NightVision：增加一个夜视镜的效果，是一个ImageEffect效果。

Outline：增加一个描边效果，主要方法通过根据法线方向扩张模型，先渲染背面产生描边效果，再正常渲染模型正面。

Earth：增加一个地球渲染效果，根据EarthRending Free修改shader光照方向计算方法，优化寄存器数量和存储数值的变量大小，优化算法。

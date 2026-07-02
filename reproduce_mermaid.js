const text = `mindmap
  root((Linux系统与网络管理))
    典型任务场景
      搭建个人开发环境并实现远程开发
        关键能力点
          配置 WSL/终端与基础工具链
          生成与管理 SSH 密钥
          编写可维护的 SSH 配置
        关键知识点
          WSL 2 与 Linux 发行版概念
          ssh-keygen / ssh-copy-id / ~/.ssh/config
          最小权限与 sudo 使用边界

      在服务器上进行快速巡检与日志取证
        关键能力点
          使用管道组合命令完成筛选与统计
          提取关键字段并形成结论
          记录可复现的命令流与结果
        关键知识点
          STDIN/STDOUT/STDERR / 重定向 / 管道
          grep / awk / sort / uniq / head
          日志格式与字段含义

      处理（服务异常/端口占用/连接失败）等典型故障
        关键能力点
          定位进程、信号与资源占用
          定位端口占用并安全终止
          基于日志还原故障现场
        关键知识点
          ps / top / kill(信号语义)
          ss / lsof
          systemctl / journalctl`;

var lines = text.split('\n');
var newLines = [];

// 检查是否为 mindmap
var isMindmap = false;
for (var i = 0; i < lines.length; i++) {
  var trimmed = lines[i].trim();
  if (trimmed === 'mindmap') {
    isMindmap = true;
    newLines.push(lines[i]);
    break;
  } else if (trimmed !== '' && !trimmed.startsWith('%%')) {
    break;
  } else {
    newLines.push(lines[i]);
  }
}

if (isMindmap) {
  var stack = []; // 存储缩进值
  
  for (var i = newLines.length; i < lines.length; i++) {
    var line = lines[i];
    var trimmed = line.trim();
    
    if (trimmed === '' || trimmed.startsWith('%%')) {
      newLines.push(line);
      continue;
    }
    
    // 计算缩进 (tab = 4 spaces)
    var indent = 0;
    for (var j = 0; j < line.length; j++) {
      if (line[j] === ' ') indent++;
      else if (line[j] === '\t') indent += 4;
      else break;
    }
    
    // 确定层级
    if (stack.length === 0) {
      stack.push(indent);
    } else {
      var top = stack[stack.length - 1];
      if (indent > top) {
        stack.push(indent);
      } else if (indent < top) {
        while (stack.length > 0 && stack[stack.length - 1] > indent) {
          stack.pop();
        }
        if (stack.length === 0 || stack[stack.length - 1] !== indent) {
          stack.push(indent);
        }
      }
    }
    
    var level = stack.length - 1;
    if (level > 5) level = 5;
    
    newLines.push(line + ':::mindmap-node-level-' + level);
  }
  console.log(newLines.join('\n'));
}

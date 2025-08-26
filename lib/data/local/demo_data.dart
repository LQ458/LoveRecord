import '../models/record.dart';

class DemoData {
  static List<Record> getDemoRecords() {
    return [
      Record.create(
        title: '今天的学习笔记',
        content: '今天学习了Flutter的状态管理，特别是Riverpod的使用。Riverpod是一个强大的状态管理库，提供了类型安全和依赖注入功能。',
        type: RecordType.study,
        tags: ['Flutter', 'Riverpod', '学习'],
      ),
      Record.create(
        title: '工作项目进展',
        content: '完成了项目的基础架构搭建，包括数据模型设计、数据库服务实现和UI组件开发。下一步需要集成AI服务。',
        type: RecordType.work,
        tags: ['项目', '开发', '架构'],
      ),
      Record.create(
        title: '周末旅行计划',
        content: '计划周末去附近的山区徒步，准备带上相机记录美丽的风景。希望天气能够配合。',
        type: RecordType.travel,
        tags: ['旅行', '徒步', '摄影'],
      ),
      Record.create(
        title: '健康日记',
        content: '今天进行了30分钟的跑步锻炼，感觉身体状态很好。明天计划进行力量训练。',
        type: RecordType.health,
        tags: ['运动', '健康', '跑步'],
      ),
      Record.create(
        title: '创意想法',
        content: '突然想到一个有趣的应用创意：结合AI和AR技术，创建一个虚拟助手应用。',
        type: RecordType.creative,
        tags: ['创意', 'AI', 'AR'],
      ),
      Record.create(
        title: '财务管理',
        content: '本月支出总结：餐饮1200元，交通300元，购物800元。需要控制购物支出。',
        type: RecordType.finance,
        tags: ['财务', '支出', '预算'],
      ),
      Record.create(
        title: '情感记录',
        content: '今天心情很好，因为完成了一个重要的项目里程碑。感谢团队的努力和配合。',
        type: RecordType.diary,
        tags: ['情感', '工作', '团队'],
      ),
    ];
  }
} 
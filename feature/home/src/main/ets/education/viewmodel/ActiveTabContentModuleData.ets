export class DataSource {
  private id: string;
  private schoolYear: string;
  private gradeInfo: string;
  private title: string;

  constructor(id: string, schoolYear: string, gradeInfo: string, title: string) {
    this.id = id;
    this.schoolYear = schoolYear;
    this.gradeInfo = gradeInfo;
    this.title = title;
  }

  getId(): string {
    return this.id;
  }

  getSchoolYear(): string {
    return this.schoolYear;
  }

  getGradeInfo(): string {
    return this.gradeInfo;
  }

  getTitle(): string {
    return this.title;
  }
}

export class Data {
  private textbooks: DataSource[] = [];
  static readonly TEXTBOOK_IDS: string[] = ['exam_001', 'exam_002', 'exercise_math_001', 'exercise_english_001'];
  static readonly SCHOOL_YEARS: string[] = ['2023-2024学年', '2022-2023学年', '2023-2024学年', '2023-2024学年'];
  static readonly GRADE_INFOS: string[] = ['高三(上)', '高二(下)', '高一数学习题集', '高二英语习题集'];
  static readonly TEXTBOOK_TITLES: string[] =
    ['2023年高考数学真题试卷-全国卷I', '2022年高考英语真题试卷-全国卷II', '高中数学必修一同步练习题库',
      '高中英语阅读理解专项训练'];

  constructor() {
    this.initTextbooks();
  }

  private initTextbooks(): void {
    for (let i = 0; i < Data.TEXTBOOK_IDS.length; i++) {
      this.textbooks.push(new DataSource(
        Data.TEXTBOOK_IDS[i],
        Data.SCHOOL_YEARS[i],
        Data.GRADE_INFOS[i],
        Data.TEXTBOOK_TITLES[i]
      ));
    }
  }

  getTextbooks(): DataSource[] {
    return this.textbooks;
  }
}
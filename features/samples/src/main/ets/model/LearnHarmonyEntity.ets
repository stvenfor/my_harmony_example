export class ArticleList {
    adminAdd?: boolean;
    apkLink?: string;
    audit?: number;
    author?: string;
    canEdit?: boolean;
    chapterId?: number;
    chapterName?: string;
    collect?: boolean;
    courseId?: number;
    desc?: string;
    descMd?: string;
    envelopePic?: string;
    fresh?: boolean;
    host?: string;
    id?: number;
    isAdminAdd?: boolean;
    link?: string;
    niceDate?: string;
    niceShareDate?: string;
    origin?: string;
    prefix?: string;
    projectLink?: string;
    publishTime?: number;
    realSuperChapterId?: number;
    selfVisible?: number;
    shareDate?: number;
    shareUser?: string;
    superChapterId?: number;
    superChapterName?: string;
    tags?: string[];
    title?: string;
    type?: number;
    userId?: number;
    visible?: number;
    zan?: number;
}

export class Links {
    articleList?: ArticleList[];
    author?: string;
    children?: string[];
    courseId?: number;
    cover?: string;
    desc?: string;
    id?: number;
    lisense?: string;
    lisenseLink?: string;
    name?: string;
    order?: number;
    parentChapterId?: number;
    type?: number;
    userControlSetTop?: boolean;
    visible?: number;
}

export class Open_sources {
    articleList?: ArticleList[];
    author?: string;
    children?: string[];
    courseId?: number;
    cover?: string;
    desc?: string;
    id?: number;
    lisense?: string;
    lisenseLink?: string;
    name?: string;
    order?: number;
    parentChapterId?: number;
    type?: number;
    userControlSetTop?: boolean;
    visible?: number;
}

export class Tools {
    articleList?: ArticleList[];
    author?: string;
    children?: string[];
    courseId?: number;
    cover?: string;
    desc?: string;
    id?: number;
    lisense?: string;
    lisenseLink?: string;
    name?: string;
    order?: number;
    parentChapterId?: number;
    type?: number;
    userControlSetTop?: boolean;
    visible?: number;
}

export class LearnHarmonyEntity {
    links?: Links;
    open_sources?: Open_sources;
    tools?: Tools;
}

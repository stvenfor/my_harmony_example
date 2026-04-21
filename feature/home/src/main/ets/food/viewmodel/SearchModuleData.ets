export interface DataSourceStyleGStyleG {
  left: number;
  right: number;
}

export interface DataSourceStyleHStyleH {
  background: string;
  contentBackground: string;
  border: string;
}

export interface DataSourceStyleAStyleA {
  height: number;
  contentHeight: number;
  borderRadius: number;
}

export interface DataSourceStyleBStyleB {
  horizontal: number;
  iconLeft: number;
  dividerMargin: DataSourceStyleGStyleG;
  inputLeft: number;
  buttonRight: number;
}

export interface DataSourceStyleCStyleC {
  size: number;
  color: string;
}

export interface DataSourceStyleDStyleD {
  height: number;
  width: number;
  color: string;
}

export interface DataSourceStyleEStyleE {
  width: string;
  height: number;
  fontSize: number;
  placeholder: string;
  placeholderColor: string;
  caretColor: string;
}

export interface DataSourceStyleFStyleF {
  width: number;
  height: number;
  fontSize: number;
  color: string;
  backgroundColor: string;
  text: string;
  paddingVertical: number;
}

export interface DataSource {
  size: DataSourceStyleAStyleA;
  spacing: DataSourceStyleBStyleB;
  icon: DataSourceStyleCStyleC;
  divider: DataSourceStyleDStyleD;
  input: DataSourceStyleEStyleE;
  button: DataSourceStyleFStyleF;
  colors: DataSourceStyleHStyleH;
}

export class DefaultSearchBarStyle implements DataSource {
  readonly size: DataSourceStyleAStyleA;
  readonly spacing: DataSourceStyleBStyleB;
  readonly icon: DataSourceStyleCStyleC;
  readonly divider: DataSourceStyleDStyleD;
  readonly input: DataSourceStyleEStyleE;
  readonly button: DataSourceStyleFStyleF;
  readonly colors: DataSourceStyleHStyleH;

  constructor() {
    this.size = {
      height: 48,
      contentHeight: 36,
      borderRadius: 18
    } as DataSourceStyleAStyleA;
    this.spacing = {
      horizontal: 16,
      iconLeft: 12,
      dividerMargin: {
        left: 8,
        right: 0
      } as DataSourceStyleGStyleG,
      inputLeft: 8,
      buttonRight: 1
    } as DataSourceStyleBStyleB;
    this.icon = {
      size: 16,
      color: '#999999'
    } as DataSourceStyleCStyleC;
    this.divider = {
      height: 14,
      width: 1,
      color: '#DDDDDD'
    } as DataSourceStyleDStyleD;
    this.input = {
      width: '60%',
      height: 36,
      fontSize: 14,
      placeholder: '一点点｜味千拉面',
      placeholderColor: '#333333',
      caretColor: '#0099FF'
    } as DataSourceStyleEStyleE;
    this.button = {
      width: 64,
      height: 32,
      fontSize: 14,
      color: '#FFFFFF',
      backgroundColor: '#0099FF',
      text: '搜索',
      paddingVertical: 6
    } as DataSourceStyleFStyleF;
    this.colors = {
      background: '#FFFFFF',
      contentBackground: '#F5F5F5',
      border: '#0099FF'
    } as DataSourceStyleHStyleH;
  }
}
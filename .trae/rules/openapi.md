## OpenAPI Rules

1. OpenAPI 采用模块化管理。
2. 禁止直接修改 `openapi.yaml` 中的大量接口定义。
3. 新增接口必须放入对应 domain 目录。
4. 修改接口前先定位对应 `path/schema` 文件。
5. 开发功能时只读取相关 domain 的 OpenAPI 文件。

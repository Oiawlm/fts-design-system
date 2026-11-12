# extraction-protocol：再提取协议

> **一句话定位**：上游源项目 fts（本地只读检出 `D:\Download\Agent Vault\悬浮中转站\悬浮中转站-main`）每个大版本后向本仓再提取的统一流程——触发判定、九步执行、对账文档模板、标签规则、角色与窗口模式；目标＝任何一轮再提取可被冷启动执行，不依赖历史会话记忆。
> **来源**：PLAN-V1 §7 提取协议要点展开；首轮实践＝2026-11-11 bootstrap（1 规划＋8 执行＋3 收尾窗口，编排详见 runbook）。
> **日期**：2026-11-11　**行数预算**：≤220 行

## 一、定位与触发

1. 提取方向：fts（上游）→ 本仓四层（`tokens/`→`platforms/`→`docs/`→`skill/`）。本仓对 fts **只读**，数值回溯靠 diff 与对账文档。
2. 触发条件（满足其一）：
   - fts 发布大版本（`vX.Y.0` tag）；
   - fts main 上视觉/动效/token 面大改——判定＝下述 diff 非空（`<上基线>`＝上一次 `fts-v*` 标签登记的 fts commit）：

```bash
git -C <fts仓> diff <上基线>..HEAD --stat -- \
  src/FloatingTransferStation.Core/Design/DesignTokens.cs \
  src/FloatingTransferStation/Resources/DesignTheme.Light.xaml \
  src/FloatingTransferStation/Resources/DesignTheme.Dark.xaml \
  src/FloatingTransferStation/Resources/MainWindowStyles.xaml \
  docs/design.md docs/design-contracts.md
```

3. 巡检口径：diff 为空＝零差异轮，只在 `reference/extractions/` 对账目录追加一行巡检记录，不走全流程、不打标签。

## 二、九步流程

| 步 | 动作 | 产出 | 自检 |
|---|---|---|---|
| 1 锚定基线 | 记 fts main HEAD commit＋`version.txt` 版本＋日期 | 基线三元组 | commit／tag／版本可互相印证 |
| 2 差异扫描 | `git diff <上基线>..HEAD` 三源（DesignTokens／双字典／design.md＋契约）逐条产出增删改；行为面大改时扩展扫描面 | 差异表（模板 §三.1） | 每行有 file:line 与处置去向 |
| 3 更新 tokens | 按 diff 逐条改 `tokens/` 四件；数值零发明；豁免清单同步维护 | 四件修订 | 每个数值可回溯到 diff 行 |
| 4 更新镜像＋对账 | 改 `platforms/` 两镜像；跑 `scripts/validate-tokens.ps1` | 计数三方一致（DTCG↔XAML↔CSS） | 脚本退出码 0 |
| 5 修订 docs | 按差异更新对应篇章；新范式/新反例入册；守行数预算与根因融合（先重构再增内容） | 篇章修订集 | 无补丁式追加 |
| 6 重建 skill | `skill/` 按集成态 docs 重建；`scripts/sync-skill.ps1` 部署 | 部署完成的 skill | 投影无旧口径残留 |
| 7 写对账文档 | 按 §三模板写 `reference/extractions/<日期>-fts-v<X.Y.Z>.md` | 对账文档 | 模板四节齐＋计数对上轮 |
| 8 打标签 | `git tag -a fts-v<X.Y.Z> -m "fts baseline <commit> (<X.Y.Z>)"` | annotated 标签 | 标签消息含 fts commit |
| 9 版本推进 | 本仓 minor +1；CHANGELOG 记两轨版本对照；发布 | 本仓新版本 | 两轨版本对照可查 |

分支纪律（全程）：每任务一分支一 worktree（主检出旁 `../fts-design-system-worktree/<slug>/`），分支创建即推送；main 同一时刻只有集成窗口可写；不 force push、不改写历史；过程产物（提示词/报告）落主检出 `handoff/`（不入库）。

## 三、对账文档模板

文件名：`reference/extractions/<日期>-fts-v<X.Y.Z>.md`（`<日期>`＝执行日，格式 YYYY-MM）。

```markdown
# <日期>-fts-v<X.Y.Z>（对账文档）
> 基线：fts commit <hash>（version.txt <X.Y.Z>，<日期>）；上基线：<fts-v 标签>（<hash>）。

## 1. 差异表（源文件 × 增删改）
| 源文件:行 | 变更 | token/文档影响 | 处置 |
（每行可回溯：本仓产物数值 ↔ fts 基线 file:line 的链不断）

## 2. 四层产物计数（TOKEN-MAP 式汇总）
| 维度 | 上轮 | 本轮 | 差异说明 |
（tokens 四件 token 数与别名数；XAML 每本键数×2；CSS 变量数；docs 篇数；skill 引用面）

## 3. validate-tokens 输出全文
（粘贴脚本完整 stdout；退出码必须为 0）

## 4. 已知缺口与移交
| # | 事项 | 类型（裁决/信息/缺口） | 留给 |
```

## 四、标签与版本规则

1. `fts-v<X.Y.Z>`＝提取基线锚：annotated tag，消息必含 fts commit hash；一基线一标签，永不改写、不重打。
2. 标签只打在 main 集成完成点（九步全绿后），不打在执行分支。
3. 本仓自身版本独立演进（v0.x 起），与 fts 版本号不联动；每轮成功再提取至少推进一个 minor，CHANGELOG 记两轨版本对照。

## 五、角色与窗口模式

| 角色 | 职责 | 产出 |
|---|---|---|
| 规划 | 差异即最小规划：裁决口径冲突、定分片与文件互斥、发执行提示词 | 差异表＋任务提示词（`handoff/`；首轮样例＝PLAN/TOKEN-MAP） |
| 执行 | 差异驱动的分片窗口；fts 仓只读；只写自有分支独占文件集 | 分支（推 origin）＋REPORT（`handoff/`） |
| 集成 | main 唯一写者：合并各分支、validate 全量、交叉引用核对、写对账文档、打标签、发版 | 集成 main＋对账文档＋标签 |

- 完成信号（派发下游的前提）：任务分支出现在 `git ls-remote --heads origin` **且** 对应 REPORT 落盘——两信号齐备才进下一步。
- 幂等恢复：REPORT 记录进度；中断后重发同一提示词文件即可续跑。
- 执行窗口共同铁律：fts 仓与部署态 skill 目录只读；公共文件（AGENTS/README/PLAN/TOKEN-MAP/runbook）执行窗口禁改；根因融合、禁止补丁式堆叠。

## 六、红线与验收

1. fts 仓全程只读（例外仅经用户显式授权的收尾窄写入，逐条登记）。
2. 数值可回溯链不断：本仓任何数值 ↔ 对账文档差异表 ↔ fts 基线 commit 的 file:line。
3. `scripts/validate-tokens.ps1` 全绿是 tokens/platforms 层的唯一验收口径，不依赖第三方工具兼容性。
4. 不捏造：执行中发现的口径冲突登记移交（REPORT 移交事项表），不静默改写规划产物。
5. `handoff/` 与本机私有产物（截图/凭据）不入库；图片资产只收协议认可的再生资产。

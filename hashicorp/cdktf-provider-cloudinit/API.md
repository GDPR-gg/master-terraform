# API Reference <a name="API Reference"></a>

## Constructs <a name="Constructs"></a>

### CloudinitProvider <a name="@cdktf/provider-cloudinit.CloudinitProvider"></a>

Represents a {@link https://www.terraform.io/docs/providers/cloudinit cloudinit}.

#### Initializers <a name="@cdktf/provider-cloudinit.CloudinitProvider.Initializer"></a>

```typescript
import { CloudinitProvider } from '@cdktf/provider-cloudinit'

new CloudinitProvider(scope: Construct, id: string, config?: CloudinitProviderConfig)
```

##### `scope`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.CloudinitProvider.parameter.scope"></a>

- *Type:* [`constructs.Construct`](#constructs.Construct)

The scope in which to define this construct.

---

##### `id`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.CloudinitProvider.parameter.id"></a>

- *Type:* `string`

The scoped construct ID.

Must be unique amongst siblings in the same scope

---

##### `config`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.CloudinitProvider.parameter.config"></a>

- *Type:* [`@cdktf/provider-cloudinit.CloudinitProviderConfig`](#@cdktf/provider-cloudinit.CloudinitProviderConfig)

---

#### Methods <a name="Methods"></a>

##### `resetAlias` <a name="@cdktf/provider-cloudinit.CloudinitProvider.resetAlias"></a>

```typescript
public resetAlias()
```


#### Properties <a name="Properties"></a>

##### `aliasInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.CloudinitProvider.property.aliasInput"></a>

```typescript
public readonly aliasInput: string;
```

- *Type:* `string`

---

##### `alias`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.CloudinitProvider.property.alias"></a>

```typescript
public readonly alias: string;
```

- *Type:* `string`

---

#### Constants <a name="Constants"></a>

##### `tfResourceType` <a name="@cdktf/provider-cloudinit.CloudinitProvider.property.tfResourceType"></a>

- *Type:* `string`

---

### Config <a name="@cdktf/provider-cloudinit.Config"></a>

Represents a {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html cloudinit_config}.

#### Initializers <a name="@cdktf/provider-cloudinit.Config.Initializer"></a>

```typescript
import { Config } from '@cdktf/provider-cloudinit'

new Config(scope: Construct, id: string, config: ConfigConfig)
```

##### `scope`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.Config.parameter.scope"></a>

- *Type:* [`constructs.Construct`](#constructs.Construct)

The scope in which to define this construct.

---

##### `id`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.Config.parameter.id"></a>

- *Type:* `string`

The scoped construct ID.

Must be unique amongst siblings in the same scope

---

##### `config`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.Config.parameter.config"></a>

- *Type:* [`@cdktf/provider-cloudinit.ConfigConfig`](#@cdktf/provider-cloudinit.ConfigConfig)

---

#### Methods <a name="Methods"></a>

##### `resetBase64Encode` <a name="@cdktf/provider-cloudinit.Config.resetBase64Encode"></a>

```typescript
public resetBase64Encode()
```

##### `resetBoundary` <a name="@cdktf/provider-cloudinit.Config.resetBoundary"></a>

```typescript
public resetBoundary()
```

##### `resetGzip` <a name="@cdktf/provider-cloudinit.Config.resetGzip"></a>

```typescript
public resetGzip()
```


#### Properties <a name="Properties"></a>

##### `id`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.Config.property.id"></a>

```typescript
public readonly id: string;
```

- *Type:* `string`

---

##### `rendered`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.Config.property.rendered"></a>

```typescript
public readonly rendered: string;
```

- *Type:* `string`

---

##### `base64EncodeInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.base64EncodeInput"></a>

```typescript
public readonly base64EncodeInput: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `boundaryInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.boundaryInput"></a>

```typescript
public readonly boundaryInput: string;
```

- *Type:* `string`

---

##### `gzipInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.gzipInput"></a>

```typescript
public readonly gzipInput: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `partInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.partInput"></a>

```typescript
public readonly partInput: ConfigPart[];
```

- *Type:* [`@cdktf/provider-cloudinit.ConfigPart`](#@cdktf/provider-cloudinit.ConfigPart)[]

---

##### `part`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.Config.property.part"></a>

```typescript
public readonly part: ConfigPart[];
```

- *Type:* [`@cdktf/provider-cloudinit.ConfigPart`](#@cdktf/provider-cloudinit.ConfigPart)[]

---

##### `base64Encode`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.base64Encode"></a>

```typescript
public readonly base64Encode: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `boundary`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.boundary"></a>

```typescript
public readonly boundary: string;
```

- *Type:* `string`

---

##### `gzip`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.Config.property.gzip"></a>

```typescript
public readonly gzip: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

#### Constants <a name="Constants"></a>

##### `tfResourceType` <a name="@cdktf/provider-cloudinit.Config.property.tfResourceType"></a>

- *Type:* `string`

---

### DataCloudinitConfig <a name="@cdktf/provider-cloudinit.DataCloudinitConfig"></a>

Represents a {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html cloudinit_config}.

#### Initializers <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.Initializer"></a>

```typescript
import { DataCloudinitConfig } from '@cdktf/provider-cloudinit'

new DataCloudinitConfig(scope: Construct, id: string, config: DataCloudinitConfigConfig)
```

##### `scope`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.parameter.scope"></a>

- *Type:* [`constructs.Construct`](#constructs.Construct)

The scope in which to define this construct.

---

##### `id`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.parameter.id"></a>

- *Type:* `string`

The scoped construct ID.

Must be unique amongst siblings in the same scope

---

##### `config`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.parameter.config"></a>

- *Type:* [`@cdktf/provider-cloudinit.DataCloudinitConfigConfig`](#@cdktf/provider-cloudinit.DataCloudinitConfigConfig)

---

#### Methods <a name="Methods"></a>

##### `resetBase64Encode` <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.resetBase64Encode"></a>

```typescript
public resetBase64Encode()
```

##### `resetBoundary` <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.resetBoundary"></a>

```typescript
public resetBoundary()
```

##### `resetGzip` <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.resetGzip"></a>

```typescript
public resetGzip()
```


#### Properties <a name="Properties"></a>

##### `id`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.id"></a>

```typescript
public readonly id: string;
```

- *Type:* `string`

---

##### `rendered`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.rendered"></a>

```typescript
public readonly rendered: string;
```

- *Type:* `string`

---

##### `base64EncodeInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.base64EncodeInput"></a>

```typescript
public readonly base64EncodeInput: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `boundaryInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.boundaryInput"></a>

```typescript
public readonly boundaryInput: string;
```

- *Type:* `string`

---

##### `gzipInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.gzipInput"></a>

```typescript
public readonly gzipInput: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `partInput`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.partInput"></a>

```typescript
public readonly partInput: DataCloudinitConfigPart[];
```

- *Type:* [`@cdktf/provider-cloudinit.DataCloudinitConfigPart`](#@cdktf/provider-cloudinit.DataCloudinitConfigPart)[]

---

##### `part`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.part"></a>

```typescript
public readonly part: DataCloudinitConfigPart[];
```

- *Type:* [`@cdktf/provider-cloudinit.DataCloudinitConfigPart`](#@cdktf/provider-cloudinit.DataCloudinitConfigPart)[]

---

##### `base64Encode`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.base64Encode"></a>

```typescript
public readonly base64Encode: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `boundary`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.boundary"></a>

```typescript
public readonly boundary: string;
```

- *Type:* `string`

---

##### `gzip`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.gzip"></a>

```typescript
public readonly gzip: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

#### Constants <a name="Constants"></a>

##### `tfResourceType` <a name="@cdktf/provider-cloudinit.DataCloudinitConfig.property.tfResourceType"></a>

- *Type:* `string`

---

## Structs <a name="Structs"></a>

### CloudinitProviderConfig <a name="@cdktf/provider-cloudinit.CloudinitProviderConfig"></a>

#### Initializer <a name="[object Object].Initializer"></a>

```typescript
import { CloudinitProviderConfig } from '@cdktf/provider-cloudinit'

const cloudinitProviderConfig: CloudinitProviderConfig = { ... }
```

##### `alias`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.CloudinitProviderConfig.property.alias"></a>

```typescript
public readonly alias: string;
```

- *Type:* `string`

Alias name.

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit#alias CloudinitProvider#alias}

---

### ConfigConfig <a name="@cdktf/provider-cloudinit.ConfigConfig"></a>

#### Initializer <a name="[object Object].Initializer"></a>

```typescript
import { ConfigConfig } from '@cdktf/provider-cloudinit'

const configConfig: ConfigConfig = { ... }
```

##### `count`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.count"></a>

```typescript
public readonly count: number | IResolvable;
```

- *Type:* `number` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `dependsOn`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.dependsOn"></a>

```typescript
public readonly dependsOn: ITerraformDependable[];
```

- *Type:* [`cdktf.ITerraformDependable`](#cdktf.ITerraformDependable)[]

---

##### `lifecycle`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.lifecycle"></a>

```typescript
public readonly lifecycle: TerraformResourceLifecycle;
```

- *Type:* [`cdktf.TerraformResourceLifecycle`](#cdktf.TerraformResourceLifecycle)

---

##### `provider`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.provider"></a>

```typescript
public readonly provider: TerraformProvider;
```

- *Type:* [`cdktf.TerraformProvider`](#cdktf.TerraformProvider)

---

##### `part`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.part"></a>

```typescript
public readonly part: ConfigPart[];
```

- *Type:* [`@cdktf/provider-cloudinit.ConfigPart`](#@cdktf/provider-cloudinit.ConfigPart)[]

part block.

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#part Config#part}

---

##### `base64Encode`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.base64Encode"></a>

```typescript
public readonly base64Encode: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#base64_encode Config#base64_encode}.

---

##### `boundary`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.boundary"></a>

```typescript
public readonly boundary: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#boundary Config#boundary}.

---

##### `gzip`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigConfig.property.gzip"></a>

```typescript
public readonly gzip: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#gzip Config#gzip}.

---

### ConfigPart <a name="@cdktf/provider-cloudinit.ConfigPart"></a>

#### Initializer <a name="[object Object].Initializer"></a>

```typescript
import { ConfigPart } from '@cdktf/provider-cloudinit'

const configPart: ConfigPart = { ... }
```

##### `content`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.ConfigPart.property.content"></a>

```typescript
public readonly content: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#content Config#content}.

---

##### `contentType`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigPart.property.contentType"></a>

```typescript
public readonly contentType: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#content_type Config#content_type}.

---

##### `filename`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigPart.property.filename"></a>

```typescript
public readonly filename: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#filename Config#filename}.

---

##### `mergeType`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.ConfigPart.property.mergeType"></a>

```typescript
public readonly mergeType: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/r/config.html#merge_type Config#merge_type}.

---

### DataCloudinitConfigConfig <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig"></a>

#### Initializer <a name="[object Object].Initializer"></a>

```typescript
import { DataCloudinitConfigConfig } from '@cdktf/provider-cloudinit'

const dataCloudinitConfigConfig: DataCloudinitConfigConfig = { ... }
```

##### `count`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.count"></a>

```typescript
public readonly count: number | IResolvable;
```

- *Type:* `number` | [`cdktf.IResolvable`](#cdktf.IResolvable)

---

##### `dependsOn`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.dependsOn"></a>

```typescript
public readonly dependsOn: ITerraformDependable[];
```

- *Type:* [`cdktf.ITerraformDependable`](#cdktf.ITerraformDependable)[]

---

##### `lifecycle`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.lifecycle"></a>

```typescript
public readonly lifecycle: TerraformResourceLifecycle;
```

- *Type:* [`cdktf.TerraformResourceLifecycle`](#cdktf.TerraformResourceLifecycle)

---

##### `provider`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.provider"></a>

```typescript
public readonly provider: TerraformProvider;
```

- *Type:* [`cdktf.TerraformProvider`](#cdktf.TerraformProvider)

---

##### `part`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.part"></a>

```typescript
public readonly part: DataCloudinitConfigPart[];
```

- *Type:* [`@cdktf/provider-cloudinit.DataCloudinitConfigPart`](#@cdktf/provider-cloudinit.DataCloudinitConfigPart)[]

part block.

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#part DataCloudinitConfig#part}

---

##### `base64Encode`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.base64Encode"></a>

```typescript
public readonly base64Encode: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#base64_encode DataCloudinitConfig#base64_encode}.

---

##### `boundary`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.boundary"></a>

```typescript
public readonly boundary: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#boundary DataCloudinitConfig#boundary}.

---

##### `gzip`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigConfig.property.gzip"></a>

```typescript
public readonly gzip: boolean | IResolvable;
```

- *Type:* `boolean` | [`cdktf.IResolvable`](#cdktf.IResolvable)

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#gzip DataCloudinitConfig#gzip}.

---

### DataCloudinitConfigPart <a name="@cdktf/provider-cloudinit.DataCloudinitConfigPart"></a>

#### Initializer <a name="[object Object].Initializer"></a>

```typescript
import { DataCloudinitConfigPart } from '@cdktf/provider-cloudinit'

const dataCloudinitConfigPart: DataCloudinitConfigPart = { ... }
```

##### `content`<sup>Required</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigPart.property.content"></a>

```typescript
public readonly content: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#content DataCloudinitConfig#content}.

---

##### `contentType`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigPart.property.contentType"></a>

```typescript
public readonly contentType: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#content_type DataCloudinitConfig#content_type}.

---

##### `filename`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigPart.property.filename"></a>

```typescript
public readonly filename: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#filename DataCloudinitConfig#filename}.

---

##### `mergeType`<sup>Optional</sup> <a name="@cdktf/provider-cloudinit.DataCloudinitConfigPart.property.mergeType"></a>

```typescript
public readonly mergeType: string;
```

- *Type:* `string`

Docs at Terraform Registry: {@link https://www.terraform.io/docs/providers/cloudinit/d/config.html#merge_type DataCloudinitConfig#merge_type}.

---




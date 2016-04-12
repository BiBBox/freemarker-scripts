<#assign liferay_ui = taglibLiferayHash["/WEB-INF/tld/liferay-ui.tld"] />
<#assign aui = taglibLiferayHash["/WEB-INF/tld/aui.tld"] />
<#assign liferay_portlet = taglibLiferayHash["/WEB-INF/tld/liferay-portlet.tld"] />
<#assign liferay_ui = taglibLiferayHash["/WEB-INF/tld/liferay-ui.tld"] />
<#assign queryUtil = staticUtil["com.liferay.portal.kernel.dao.orm.QueryUtil"]/>
<#assign AssetCategoryLocalService = serviceLocator.findService("com.liferay.portlet.asset.service.AssetCategoryLocalService")>
<#assign AssetVocabularyLocalService = serviceLocator.findService("com.liferay.portlet.asset.service.AssetVocabularyLocalService")>
<#assign listVecoblaries = AssetVocabularyLocalService.getGroupVocabularies(themeDisplay.getSiteGroupId())>
<#assign AssetVocabularyLocalService = serviceLocator.findService("com.liferay.portlet.asset.service.AssetVocabularyLocalService")>

<#assign debug = 0 />


<#list entries as entry>

 	<#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, entry) />

	<#assign entry = entry />
	<#assign assetRenderer = entry.getAssetRenderer() />
	<#assign entryTitle = htmlUtil.escape(assetRenderer.getTitle(locale)) />
	<#assign journalArticle = assetRenderer.getArticle()/>
	<#assign docXml = saxReaderUtil.read(journalArticle.getContent()) />
	<#assign rootElement = docXml.getRootElement() />
	<#assign xPathSelector = saxReaderUtil.createXPath("dynamic-element[@name='title']") />
	<#assign title = xPathSelector.selectSingleNode(rootElement).getStringValue() /> 
	<#assign xPathSelector = saxReaderUtil.createXPath("dynamic-element[@name='description']") />
	<#assign description = xPathSelector.selectSingleNode(rootElement).getStringValue() /> 
	<#assign xPathSelector = saxReaderUtil.createXPath("dynamic-element[@name='href']") />
	<#assign href = xPathSelector.selectSingleNode(rootElement).getStringValue() /> 
	<#assign xPathSelector = saxReaderUtil.createXPath("dynamic-element[@name='icon']") />
	<#assign icon = xPathSelector.selectSingleNode(rootElement).getStringValue() /> 
	<#assign xPathSelector = saxReaderUtil.createXPath("dynamic-element[@name='anchor']") />
	<#assign anchor = xPathSelector.selectSingleNode(rootElement).getStringValue() /> 



    <#-- TODO
        ADD a BAckLink Here, or in the WebContent Display Templete
    -->
	<#if debug == 1>

		<h4>${title}</h4>
		<h4>${description}</h4>
		<h4>${href}</h4>
		<h4>${icon}</h4>
		<h4>${anchor}</h4>
	</#if>

   <div id="externalContentList"> 
	<table>
		<tr>
			<td valign="top">
				<div class="icon"><a href="${viewURL}">
					<img style="box-shadow: 4px 4px 4px #7C7C7C;" src="${icon}" width="80" alt=""> </a>
				</div>  
			</td>
			<td valign="top">
				<div style="margin-left:15px;" class="text">
					<h4>${title} <@getEditIcon /> </h4>

					<p>${description}</p><bf>
					<a href="${viewURL}" target="_blank">read more ........</a> <br>
					<@getSocialBookmarks /> 
				</div>
			</td>

		</tr>
	</table>
    </div>


</#list>






<#macro getDiscussion>
	<#if validator.isNotNull(assetRenderer.getDiscussionPath()) && (enableComments == "true")>
		<br />

		<#assign discussionURL = renderResponse.createActionURL() />

		${discussionURL.setParameter("struts_action", "/asset_publisher/" + assetRenderer.getDiscussionPath())}

		<@liferay_ui["discussion"]
			className=entry.getClassName()
			classPK=entry.getClassPK()
			formAction=discussionURL?string
			formName="fm" + entry.getClassPK()
			ratingsEnabled=enableCommentRatings == "true"
			redirect=portalUtil.getCurrentURL(request)
			subject=assetRenderer.getTitle(locale)
			userId=assetRenderer.getUserId()
		/>
	</#if>
</#macro>

<#macro getEditIcon>
	<#if assetRenderer.hasEditPermission(themeDisplay.getPermissionChecker())>
		<#assign redirectURL = renderResponse.createRenderURL() />

		${redirectURL.setParameter("struts_action", "/asset_publisher/add_asset_redirect")}
		${redirectURL.setWindowState("pop_up")}

		<#assign editPortletURL = assetRenderer.getURLEdit(renderRequest, renderResponse, windowStateFactory.getWindowState("pop_up"), redirectURL) />

		<#if validator.isNotNull(editPortletURL)>
			<#assign title = languageUtil.format(locale, "edit-x", htmlUtil.escape(assetRenderer.getTitle(locale))) />

			<@liferay_ui["icon"]
				image="edit"
				message=title
				url="javascript:Liferay.Util.openWindow({dialog: {width: 960}, id:'" + renderResponse.getNamespace() + "editAsset', title: '" + title + "', uri:'" + htmlUtil.escapeURL(editPortletURL.toString()) + "'});"
			/>
		</#if>
	</#if>
</#macro>

<#macro getFlagsIcon>
	<#if enableFlags == "true">
		<@liferay_ui["flags"]
			className=entry.getClassName()
			classPK=entry.getClassPK()
			contentTitle=entry.getTitle(locale)
			label=false
			reportedUserId=entry.getUserId()
		/>
	</#if>
</#macro>

<#macro getMetadataField fieldName>
	<#if stringUtil.split(metadataFields)?seq_contains(metadataFieldName)>
		<span class="metadata-entry metadata-"${metadataFieldName}">
			<#assign dateFormat = "dd MMM yyyy - HH:mm:ss" />

			<#if fieldName == "author">
				<@liferay.language key="by" /> ${portalUtil.getUserName(assetRenderer.getUserId(), assetRenderer.getUserName())}
			<#elseif fieldName == "categories">
				<@liferay_ui["asset-categories-summary"]
					className=entry.getClassName()
					classPK=entry.getClassPK()
					portletURL=renderResponse.createRenderURL()
				/>
			<#elseif fieldName == "create-date">
				${dateUtil.getDate(entry.getCreateDate(), dateFormat, locale)}
			<#elseif fieldName == "expiration-date">
				${dateUtil.getDate(entry.getExpirationDate(), dateFormat, locale)}
			<#elseif fieldName == "modified-date">
				${dateUtil.getDate(entry.getModifiedDate(), dateFormat, locale)}
			<#elseif fieldName == "priority">
				${entry.getPriority()}
			<#elseif fieldName == "publish-date">
				${ddateUtil.getDate(entry.getPublishDate(), dateFormat, locale)}
			<#elseif fieldName == "tags">
				<@liferay_ui["asset-tags-summary"]
					className=entry.getClassName()
					classPK=entry.getClassPK()
					portletURL=renderResponse.createRenderURL()
				/>
			<#elseif fieldName == "view-count">
				<@liferay_ui["icon"]
					image="history"
				/>

				${entry.getViewCount()} <@liferay.language key="views" />
			</#if>
		</span>
	</#if>
</#macro>

<#macro getPrintIcon>
	<#if enablePrint == "true" >
		<#assign printURL = renderResponse.createRenderURL() />

		${printURL.setParameter("struts_action", "/asset_publisher/view_content")}
		${printURL.setParameter("assetEntryId", entry.getEntryId()?string)}
		${printURL.setParameter("viewMode", "print")}
		${printURL.setParameter("type", entry.getAssetRendererFactory().getType())}

		<#if (validator.isNotNull(assetRenderer.getUrlTitle()))>
			<#if (assetRenderer.getGroupId() != themeDisplay.getScopeGroupId())>
				${printURL.setParameter("groupId", assetRenderer.getGroupId()?string)}
			</#if>

			${printURL.setParameter("urlTitle", assetRenderer.getUrlTitle())}
		</#if>

		${printURL.setWindowState("pop_up")}

		<@liferay_ui["icon"]
			image="print"
			message="print"
			url="javascript:Liferay.Util.openWindow({dialog: {width: 960}, id:'" + renderResponse.getNamespace() + "printAsset', title: '" + languageUtil.format(locale, "print-x-x", ["aui-helper-hidden-accessible", htmlUtil.escape(assetRenderer.getTitle(locale))]) + "', uri: '" + htmlUtil.escapeURL(printURL.toString()) + "'});"
		/>
	</#if>
</#macro>

<#macro getRatings>
	<#if (enableRatings == "true")>
		<div class="asset-ratings">
			<@liferay_ui["ratings"]
				className=entry.getClassName()
				classPK=entry.getClassPK()
			/>
		</div>
	</#if>
</#macro>

<#macro getRelatedAssets>
	<#if enableRelatedAssets == "true">
		<@liferay_ui["asset-links"]
			assetEntryId=entry.getEntryId()
		/>
	</#if>
</#macro>

<#macro getSocialBookmarks>
	<#if enableSocialBookmarks == "true">
		<@liferay_ui["social-bookmarks"]
			displayStyle="${socialBookmarksDisplayStyle}"
			target="_blank"
			title=entry.getTitle(locale)
			url=viewURL
		/>
	</#if>
</#macro>